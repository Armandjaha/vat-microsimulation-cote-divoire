********************************************************************************
* 06_01_sensitivity_taxation.do
*
* OBJECTIVE:
* Sensitivity analysis of VAT incidence to alternative assumptions about the
* effective application of VAT at item level.
*
* EMPIRICAL RATIONALE:
* The baseline (strict) scenario assumes full effective taxation of all
* taxable purchases (alpha = 1).
*
* However, empirical evidence from African countries suggests that actual VAT
* collection is substantially below its theoretical potential.
*
* According to UNECA (2019, ERA, Chapter 3):
* - VAT collection efficiency is often below 50% in African countries.
* - VAT gaps frequently exceed 50%, and may reach 70–90% in some cases.
*
* This implies that the effective taxation rate (alpha) is significantly below 1.
*
* Based on this empirical distribution, three scenarios are defined:
*
*   1) Pessimistic scenario (high informality):
*      alpha = 0.30
*      Rationale: corresponds to countries with VAT gaps around 70%,
*      reflecting high informality and weak compliance.
*
*   2) Prudent / baseline scenario:
*      alpha = 0.50
*      Rationale: corresponds to the central empirical finding that VAT
*      collection efficiency is below 50% in many African countries.
*
*   3) Intermediate scenario:
*      alpha = 0.60 (uniform) or differentiated by VAT category
*      Rationale: reflects partial improvement in compliance and reduced VAT gap.
*
* IMPORTANT:
* These coefficients should not be interpreted as direct compliance rates, but
* as reduced-form approximations of overall VAT effectiveness incorporating:
* - informality
* - exemptions and reduced rates
* - administrative inefficiencies
*
* OUTPUTS:
*   - household-level VAT under each scenario
*   - effective VAT rates under each scenario
*   - decile tables
*   - CEQ-style summary indices by scenario
*   - sensitivity dataset saved for later use
********************************************************************************

use "$OUTPUT/final_data/conso_clean.dta", clear

********************************************************************************
* STEP 0 — Validation
********************************************************************************

assert !missing(hhid, hhweight, depan_w, r_vat_official)
assert depan_w > 0
assert r_vat_official >= 0

********************************************************************************
* STEP 1 — Baseline strict scenario (alpha = 1)
********************************************************************************

gen vat_item_strict = depan_w * r_vat_official
label variable vat_item_strict ///
"VAT item burden - strict scenario (full taxation)"

********************************************************************************
* STEP 2 — Pessimistic scenario (alpha = 0.30)
********************************************************************************

local alpha_pessimistic = 0.30

gen vat_item_pessimistic = `alpha_pessimistic' * vat_item_strict
label variable vat_item_pessimistic ///
"VAT item burden - pessimistic scenario (30% effective taxation)"

********************************************************************************
* STEP 3 — Prudent scenario (alpha = 0.50)
********************************************************************************

local alpha_prudent = 0.50

gen vat_item_prudent = `alpha_prudent' * vat_item_strict
label variable vat_item_prudent ///
"VAT item burden - prudent scenario (50% effective taxation)"

********************************************************************************
* STEP 4 — Intermediate scenario (alpha = 0.60)
********************************************************************************

local alpha_intermediate = 0.60

gen vat_item_inter = `alpha_intermediate' * vat_item_strict
label variable vat_item_inter ///
"VAT item burden - intermediate scenario (60% effective taxation)"


********************************************************************************
* STEP 5 — Aggregation to household level
********************************************************************************

sort hhid

foreach var in strict pessimistic prudent inter  {

    by hhid: egen vat_`var' = total(vat_item_`var')
    label variable vat_`var' ///
    "Total VAT paid - `var' scenario"
}


********************************************************************************
* STEP 6 — Consumption aggregation
********************************************************************************

by hhid: egen conso_w = total(depan_w)

********************************************************************************
* STEP 7 — Effective VAT rates
********************************************************************************

foreach var in strict pessimistic prudent inter  {

    gen eff_vat_`var' = vat_`var' / conso_w
    label variable eff_vat_`var' ///
    "Effective VAT rate - `var' scenario"
}


********************************************************************************
* STEP 8 — Welfare ranking (fixed baseline for comparability)
********************************************************************************
*
* IMPORTANT:
* We fix the welfare ranking (deciles) using baseline consumption (conso_w).
* This ensures that differences across scenarios reflect ONLY changes in
* taxation assumptions, not re-ranking effects.
*
********************************************************************************

xtile decile = conso_w [pw=hhweight], n(10)

label define dec_lbl 1 "D1 poorest" 2 "D2" 3 "D3" 4 "D4" 5 "D5" ///
                     6 "D6" 7 "D7" 8 "D8" 9 "D9" 10 "D10 richest", replace

label values decile dec_lbl
label variable decile ///
"Decile of baseline welfare (winsorized total consumption)"

********************************************************************************
* STEP 9 — Robustness diagnostics: effective VAT rates by scenario
********************************************************************************
*
* Objective:
* Compare how effective VAT rates change across scenarios, holding the same
* welfare ranking.
*
********************************************************************************

preserve
collapse (mean) eff_vat_strict eff_vat_pessimistic eff_vat_prudent eff_vat_inter ///
    [pw=hhweight], by(decile)

export excel using "$TABLES/06_01_decile_effective_rates_by_scenario.xlsx", ///
    firstrow(variables) replace
restore

********************************************************************************
* STEP 9b — VAT shares (distributional burden)
********************************************************************************

preserve
collapse (sum) vat_strict vat_pessimistic vat_prudent vat_inter ///
    [pw=hhweight], by(decile)

foreach v in vat_strict vat_pessimistic vat_prudent vat_inter {
    egen total_`v' = total(`v')
    gen share_`v' = `v' / total_`v'
}

export excel using "$TABLES/06_01_decile_vat_shares_by_scenario.xlsx", ///
    firstrow(variables) replace
restore

********************************************************************************
* STEP 10 — CEQ-style robustness analysis
********************************************************************************
*
* Objective:
* Test whether progressivity conclusions are robust to alternative taxation
* assumptions.
*
********************************************************************************

capture which ineqdeco
if _rc ssc install ineqdeco

capture which conindex
if _rc ssc install conindex

gen market_income = conso_w

gen consumable_income_strict      = market_income - vat_strict
gen consumable_income_pessimistic = market_income - vat_pessimistic
gen consumable_income_prudent     = market_income - vat_prudent
gen consumable_income_inter       = market_income - vat_inter

* Gini initial
quietly ineqdeco market_income [aw=hhweight]
scalar G_market = r(gini)

tempname results
postfile `results' str20 scenario ///
    double g_market g_after c_vat kakwani rs ///
    using "$OUTPUT/final_data/06_01_ceq_summary_scenarios.dta", replace

foreach s in strict pessimistic prudent inter {

    quietly ineqdeco consumable_income_`s' [aw=hhweight]
    scalar G_after = r(gini)

    quietly conindex vat_`s' [pw=hhweight], ///
        rankvar(conso_w) truezero
    scalar C_vat = r(CI)

    scalar Kakwani = C_vat - G_market
    scalar RS = G_after - G_market

    post `results' ("`s'") ///
        (G_market) (G_after) (C_vat) (Kakwani) (RS)
}

postclose `results'

use "$OUTPUT/final_data/06_01_ceq_summary_scenarios.dta", clear

export excel using "$TABLES/06_01_ceq_summary_scenarios.xlsx", ///
    firstrow(variables) replace

use "$OUTPUT/final_data/06_01_ceq_summary_scenarios.dta", clear

gen progressive = (kakwani > 0)
label variable progressive "1 = progressive, 0 = regressive"

egen min_kakwani = min(kakwani)
gen robust_regressive = (min_kakwani < 0)

save "$OUTPUT/final_data/06_01_ceq_summary_scenarios.dta", replace


********************************************************************************
* END
********************************************************************************
