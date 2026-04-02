********************************************************************************
* 01_prepare_data.do
*
* OBJECTIVE:
* Construct a clean, consistent, and economically meaningful consumption dataset
* for VAT incidence analysis based on EHCVM data.
*
* DATA STRUCTURE:
* - Unit of observation: (household × product × acquisition method)
* - Approximately 60 observations per household
* - Around 422 distinct consumption items
*
* KEY VARIABLES:
* - depan   : annual expenditure per item
* - modep   : mode of acquisition (purchase, own-consumption, etc.)
* - inclus  : indicator for inclusion in official consumption aggregate
* - hhid    : household identifier
*
* METHODOLOGICAL APPROACH:
*
* 1. Data validation and cleaning
*    - Inspect distribution of expenditures (heavy-tailed by nature)
*
* 2. Restriction to relevant consumption
*    - Keep only items included in the official consumption aggregate (inclus == 1)
*    - Restrict to market-based transactions (modep == 1)
*
*     This ensures consistency with national accounts and VAT applicability
*
* 3. Treatment of extreme values
*    - Apply winsorization at the 99th percentile (depan_w)
*    - Preserve both raw and winsorized versions for robustness analysis
*
* 4. Construction of household-level aggregates
*    - Aggregate expenditures from item-level to household-level
*    - Compute:
*         • total consumption (conso)
*         • winsorized consumption (conso_w)
*         • number of items (n_items)
*
*    - Household characteristics (hhweight, region, milieu) are merged separately
*
* 5. Final dataset
*    - One observation per household
*    - Includes both consumption aggregates and household characteristics
*    - Log-transformed variables generated for diagnostic and analytical purposes
*
* CEQ FRAMEWORK INTERPRETATION:
*
* - We move from:
*       Total consumption (including non-monetary components)
*   to:
*       Market-based consumption (proxy for taxable base)
*
* - Non-monetary components excluded:
*       • own-consumption
*       • gifts/transfers in kind
*       • imputed values (e.g., rent)
*
* - Final dataset is consistent with a partial CEQ framework focusing on
*   indirect taxation (VAT incidence).
*
********************************************************************************


di as text ">>> STEP 1: Loading raw consumption data"

use "$DATA/ehcvm_conso_civ2021.dta", clear

********************************************************************************
* STEP 2 — Inspect dataset structure
********************************************************************************

di as text ">>> Inspecting dataset structure"

describe
count

* Key identifiers must be present
assert !missing(hhid)
assert !missing(codpr)

********************************************************************************
* STEP 3 — Clean expenditure values
********************************************************************************

di as text ">>> Cleaning expenditure values (depan)"

* Identify problematic values
count if depan <= 0
sum depan if depan <= 0

* Inspect distribution (important for detecting outliers)
sum depan, detail
list if depan >= 25000000

********************************************************************************
* STEP 4 — Restrict to official consumption aggregate
********************************************************************************

di as text ">>> Keeping only items included in final consumption aggregate"

* Variable 'inclus':
* =1 → included in official consumption aggregate
* =0 → excluded (technical items, inconsistencies, etc.)

keep if inclus == 1
sum depan, detail

* Justification:
* Ensures consistency with official consumption definition

********************************************************************************
* STEP 5 — Restrict to market-based consumption
********************************************************************************

di as text ">>> Restricting to market-based consumption (VAT-relevant)"

* Variable 'modep':
* 1 = Purchase (market transaction)
* 2 = Own-consumption
* 3 = Gift
* 4 = Use value (durables)
* 5 = Imputed rent

* CEQ assumption:
* VAT applies only to market transactions

keep if modep == 1
sum depan, detail

* IMPORTANT:
* This excludes:
* - agricultural self-consumption
* - non-monetary transfers
* - imputed rents
* - non-market services

********************************************************************************
* STEP 6 — Diagnostics after filtering
********************************************************************************

di as text ">>> Diagnostics after filtering"

count
sum depan, detail

/*After restricting to market-based consumption and excluding non-relevant items,
the distribution of expenditures becomes significantly less skewed,
though it remains right-tailed as expected.*/

* Check COICOP distribution
tab coicop

* Check regional structure
tab region

********************************************************************************
* STEP 7 — Handle extreme values (robustness)
********************************************************************************

di as text ">>> Handling extreme values (winsorization)"

* Motivation:
* Expenditure distribution is highly skewed (heavy tail),
* which may bias incidence results

gen log_depan = log(depan)
histogram log_depan
graph save "$FIGS/log_depan_af_cleaning.gph" , replace


/*The distribution of household expenditures exhibits a log-normal pattern,
consistent with standard findings in the consumption literature.
*/


sum depan, detail
local p99 = r(p99)

gen depan_w = depan

* Winsorize at the 99th percentile
replace depan_w = `p99' if depan > `p99'

* NOTE:
* - 'depan'  = raw values
* - 'depan_w' = robust version

sum depan_w, detail


********************************************************************************
* STEP 8 — Save cleaned detailed dataset
********************************************************************************

di as text ">>> Saving cleaned consumption dataset"

save "$OUTPUT/final_data/conso_clean.dta", replace

********************************************************************************
* STEP 9 — Construct household-level aggregates
********************************************************************************

di as text ">>> Aggregating to household level"

* IMPORTANT:
* We do NOT use weights here because weights are at household level
* and already duplicated across product lines

sort hhid

* Household total consumption (raw)
by hhid: egen conso = total(depan)

* Household total consumption (winsorized)
by hhid: egen conso_w = total(depan_w)

* Number of consumption items observed for the household
by hhid: egen n_items = count(codpr)

* Keep only one row per household after household totals are created
by hhid: gen hh_tag = (_n == 1)
keep if hh_tag == 1
drop hh_tag

* Keep only household-level variables needed for the next steps
keep hhid conso conso_w n_items

* Generate log household consumption after aggregation

gen lconso   = log(conso)
gen lconso_w = log(conso_w)

save "$OUTPUT/final_data/conso_temp.dta", replace


********************************************************************************
* STEP 10 — Merge household characteristics
********************************************************************************

di as text ">>> Merging household characteristics"

merge 1:1 hhid using "$OUTPUT/final_data/hh_vars.dta"

tab _merge

keep if _merge == 3
drop _merge


********************************************************************************
* STEP 11 — Household-level diagnostics
********************************************************************************

di as text ">>> Household-level diagnostics"

sum conso, detail
sum conso_w, detail
sum n_items

count if missing(hhid, conso, conso_w, n_items, hhweight, region, milieu)

histogram lconso, normal
graph save "$FIGS/log_depan_af_cleaning_1.gph" , replace


save "$OUTPUT/final_data/hh_conso.dta", replace

di as result ">>> STEP 1 COMPLETED: Household consumption dataset saved successfully"


********************************************************************************
* END
********************************************************************************

di as result ">>> STEP 1 COMPLETED: Clean consumption base ready for tax analysis"