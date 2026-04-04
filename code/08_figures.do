********************************************************************************
* 08_figures.do
*
* OBJECTIVE:
* Produce all figures for VAT incidence analysis (CEQ-style).
*
* CONTENT:
* - Effective VAT rate by decile
* - Share of total VAT by decile
* - VAT concentration curve
* - Lorenz vs VAT concentration
* - VAT by COICOP
* - Scatter VAT vs consumption
*
* NOTE:
* Graphs are saved in $FIGS
********************************************************************************

use "$OUTPUT/final_data/fiscal_data_analysis_ready.dta", clear

set scheme s1color

********************************************************************************
* STEP 1 — Create deciles
********************************************************************************

*xtile decile = conso_w [pw=hhweight], n(10)

********************************************************************************
* STEP 2 — Effective VAT rate by decile
********************************************************************************

preserve
collapse (mean) eff_vat_w [pw=hhweight], by(decile)

twoway line eff_vat_w decile, ///
    lwidth(medthick) ///
    lcolor(navy) ///
    title("Effective VAT rate by decile") ///
    ytitle("VAT / consumption") ///
    xtitle("Consumption decile") ///
    ylabel(0(.02).20, angle(horizontal))

graph export "$FIGS/fig1_vat_rate_by_decile.png", replace
restore

********************************************************************************
* STEP 3 — Share of total VAT by decile
********************************************************************************

preserve
collapse (sum) vat_sum = vat_w [pw=hhweight], by(decile)

egen total = total(vat_sum)
gen share = vat_sum / total

graph bar share, over(decile) ///
    bar(1, color(navy)) ///
    title("Share of total VAT by decile") ///
    ytitle("Share of VAT")

graph export "$FIGS/fig2_vat_share_by_decile.png", replace
restore

********************************************************************************
* STEP 4 — VAT concentration curve
********************************************************************************

sort conso_w

gen w = hhweight

gen cum_pop = sum(w)
replace cum_pop = cum_pop / cum_pop[_N]

gen cum_vat = sum(vat_w * w)
replace cum_vat = cum_vat / cum_vat[_N]

twoway line cum_vat cum_pop, ///
    lcolor(navy) ///
    lwidth(medthick) ///
    title("VAT concentration curve") ///
    ytitle("Cumulative VAT share") ///
    xtitle("Cumulative population share")

graph export "$FIGS/fig3_concentration_vat.png", replace

********************************************************************************
* STEP 5 — Lorenz vs VAT
********************************************************************************

gen cum_conso = sum(conso_w * w)
replace cum_conso = cum_conso / cum_conso[_N]

twoway ///
(line cum_vat cum_pop, lcolor(navy) lwidth(medthick)) ///
(line cum_conso cum_pop, lcolor(maroon) lpattern(dash)) ///
(line cum_pop cum_pop, lcolor(gs10) lpattern(dot)), ///
legend(label(1 "VAT") label(2 "Consumption") label(3 "Equality")) ///
title("Concentration vs Lorenz curves")

graph export "$FIGS/fig4_lorenz_vs_vat.png", replace

********************************************************************************
* STEP 6 — VAT by COICOP
********************************************************************************

use "$OUTPUT/final_data/conso_clean.dta", clear

gen vat_item_w = depan_w * r_vat_final

collapse (sum) vat = vat_item_w [pw=hhweight], by(coicop)

gsort -vat

graph bar vat, over(coicop, sort(1) descending) ///
    title("VAT by consumption category") ///
    ytitle("Total VAT")

graph export "$FIGS/fig5_vat_by_coicop.png", replace

********************************************************************************
* STEP 7 — VAT vs consumption (micro relationship)
********************************************************************************

use "$OUTPUT/final_data/fiscal_data_analysis_ready.dta", clear

twoway ///
(scatter vat_w conso_w, msize(vsmall) mcolor(gs8)) ///
(lfit vat_w conso_w, lcolor(navy)), ///
title("VAT vs consumption") ///
ytitle("VAT") ///
xtitle("Consumption")

graph export "$FIGS/fig6_vat_vs_consumption.png", replace

********************************************************************************
* END
********************************************************************************

di as result ">>> All figures successfully generated"