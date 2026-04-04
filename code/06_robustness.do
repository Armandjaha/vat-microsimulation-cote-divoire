********************************************************************************
* 06_robustness.do
********************************************************************************

use "$OUTPUT/final_data/fiscal_data_analysis_ready.dta", clear

* Ranking 1: raw consumption
xtile dec_raw = conso [pw=hhweight], n(10)
preserve
collapse (mean) eff_vat [pw=hhweight], by(dec_raw)
export excel using "$TABLES/06_robustness_raw_consumption.xlsx", firstrow(variables) replace
restore

* Ranking 2: winsorized consumption
xtile dec_w = conso_w [pw=hhweight], n(10)
preserve
collapse (mean) eff_vat_w [pw=hhweight], by(dec_w)
export excel using "$TABLES/06_robustness_winsorized_consumption.xlsx", firstrow(variables) replace
restore