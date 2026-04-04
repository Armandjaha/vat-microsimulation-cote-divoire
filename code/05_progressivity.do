********************************************************************************
* 05_progressivity.do
*
* OBJECTIVE:
* Measure VAT progressivity using concentration-based indicators
* consistent with CEQ-style distributive analysis.
********************************************************************************

use "$OUTPUT/final_data/fiscal_data_analysis_ready.dta", clear

* Ranking by welfare
sort conso_w
gen w = hhweight

* If available in your Stata environment, use ineqdeco / conindex packages
* Otherwise, produce grouped approximations by decile.
ssc install ineqdeco
ssc install conindex

*ineqdeco conso_w [pw=hhweight]
*conindex vat_w [pw=hhweight], rankvar(conso_w)
*xtile decile = conso_w [pw=hhweight], n(10)

* Gini
ineqdeco conso_w [pw=hhweight]
scalar G = r(gini)

* Concentration TVA (solution propre)
conindex vat_w [pw=hhweight], rankvar(conso_w) truezero
scalar C = r(CI)

* Kakwani
scalar K = C - G

display "Gini (consumption): " %6.4f G
display "Concentration (VAT): " %6.4f C
display "Kakwani index: " %6.4f K

********************************************************************************
* STEP 1 — Lorenz-style grouped distribution of consumption
********************************************************************************
preserve
collapse (sum) conso_sum = conso_w [pw=hhweight], by(decile)
egen total_conso = total(conso_sum)
gen conso_share = conso_sum / total_conso
gen cum_conso_share = sum(conso_share)
gen pop_share = 0.1 * _n

export excel using "$TABLES/05_lorenz_grouped_consumption.xlsx", firstrow(variables) replace
restore

********************************************************************************
* STEP 2 — Concentration-style grouped distribution of VAT
********************************************************************************
preserve
collapse (sum) vat_sum = vat_w [pw=hhweight], by(decile)
egen total_vat = total(vat_sum)
gen vat_share = vat_sum / total_vat
gen cum_vat_share = sum(vat_share)
gen pop_share = 0.1 * _n

export excel using "$TABLES/05_concentration_grouped_vat.xlsx", firstrow(variables) replace
restore