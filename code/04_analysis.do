********************************************************************************
* 04_analysis.do
********************************************************************************

use "$DATA/base_fiscale.dta", clear

* Déciles
xtile decile = market_income [pw=hhweight], n(10)

* Taux implicite
gen tax_rate = tva / conso

* Résumé
collapse (mean) tax_rate conso tva ///
    [pw=hhweight], by(decile)

* Export tableau
export excel using "$TABLES/tax_by_decile.xlsx", replace

* Graphique
twoway line tax_rate decile, ///
    title("Taux implicite de TVA par décile") ///
    ytitle("Taux") xtitle("Décile")

graph export "$FIGS/tax_progressivity.png", replace