********************************************************************************
* 03_compute_taxes.do
********************************************************************************

use "$DATA/conso_mapped.dta", clear

* Traitement informalité
gen taxable = (modep == 1)

replace taux_tva = taux_tva * taxable

* TVA par produit
gen tva_item = taux_tva * depan

* Agrégation ménage
collapse (sum) conso = depan tva = tva_item ///
    [pw=hhweight], by(hhid)

* Concepts CEQ
gen market_income     = conso
gen consumable_income = conso - tva

save "$DATA/base_fiscale.dta", replace