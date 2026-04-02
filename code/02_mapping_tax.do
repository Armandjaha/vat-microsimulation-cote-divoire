********************************************************************************
* 02_mapping_tax.do
********************************************************************************

use "$DATA/conso_clean.dta", clear

* Charger mapping fiscal
merge m:1 codpr using "$DATA/mapping_fiscal.dta"

* Vérification
tab _merge

* Garder seulement les appariés
keep if _merge == 3
drop _merge

* Vérifier taux
summ taux_tva

save "$DATA/conso_mapped.dta", replace