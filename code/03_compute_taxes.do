********************************************************************************
* 03_compute_taxes.do
*
* OBJECTIVE:
* Compute household-level VAT incidence using microdata from EHCVM.
*
* APPROACH:
* The script applies product-level VAT rates to observed consumption in order
* to estimate the tax burden borne by each household. The process follows a
* standard microsimulation approach consistent with CEQ methodology.
*
* KEY STEPS:
* 1. Ensure fiscal consistency by excluding out-of-scope items from taxation.
* 2. Compute VAT at the product level (consumption × VAT rate).
* 3. Aggregate consumption and VAT to the household level.
* 4. Derive effective VAT rates (VAT / total consumption).
* 5. Merge household characteristics for distributional analysis.
*
* ECONOMIC INTERPRETATION:
* - VAT is assumed to be fully shifted to consumers (static incidence).
* - Effective VAT rate measures the share of consumption captured by VAT.
* - Results can be used to assess the regressivity or progressivity of VAT.
*
* DATA STRUCTURE:
* - Unit of observation (input): household × product
* - Unit of observation (output): household
*
* IMPORTANT ASSUMPTIONS:
* - Only market transactions are included (modep == 1 applied upstream).
* - VAT rates are correctly assigned through the mapping file.
* - Out-of-scope items (hors_champ == 1) are not taxed.
*
* OUTPUT:
* Household-level dataset including:
* - total consumption (raw and winsorized)
* - total VAT paid
* - effective VAT rate
* - CEQ proxy income concepts
*
* AUTHOR: Armand Djaha, MSc
********************************************************************************

********************************************************************************
* 03_compute_taxes.do
********************************************************************************

use "$OUTPUT/final_data/conso_clean.dta", clear

********************************************************************************
* STEP 1 — Ensure VAT consistency
********************************************************************************

* No VAT for out-of-scope items
replace r_vat_final = 0 if hors_champ == 1

********************************************************************************
* STEP 2 — Compute VAT at item level
********************************************************************************

gen vat_item   = depan   * r_vat_final
gen vat_item_w = depan_w * r_vat_final

********************************************************************************
* STEP 3 — Aggregate to household level
********************************************************************************

di as text ">>> Aggregating to household level"

sort hhid

* Total consumption
by hhid: egen conso   = total(depan)
by hhid: egen conso_w = total(depan_w)

* VAT
by hhid: egen vat   = total(vat_item)
by hhid: egen vat_w = total(vat_item_w)

* Number of items
by hhid: egen n_items = count(codpr)

********************************************************************************
* STEP 4 — Effective VAT rate
********************************************************************************

gen eff_vat   = vat   / conso
gen eff_vat_w = vat_w / conso_w

********************************************************************************
* STEP 5 — Reduce to one observation per household
********************************************************************************

by hhid: gen hh_tag = (_n == 1)
keep if hh_tag == 1
drop hh_tag

********************************************************************************
* STEP 6 — Merge household characteristics
********************************************************************************

di as text ">>> Merging household characteristics"

merge 1:1 hhid using "$OUTPUT/final_data/hh_vars.dta"

tab _merge
keep if _merge == 3
drop _merge

********************************************************************************
* STEP 7 — Log variables
********************************************************************************

gen lconso   = log(conso)
gen lconso_w = log(conso_w)

********************************************************************************
* STEP 8 — CEQ proxy concepts
********************************************************************************

gen market_income     = conso
gen consumable_income = conso - vat

********************************************************************************
* STEP 9 — Diagnostics
********************************************************************************

sum conso vat eff_vat, detail


********************************************************************************
* STEP 9 — Keep only household-level variables
********************************************************************************

keep ///
    hhid year ///
    hhweight ///
    region milieu ///
    conso conso_w ///
    vat vat_w ///
    eff_vat eff_vat_w ///
    n_items ///
    lconso lconso_w ///
    market_income consumable_income

order hhid conso vat eff_vat hhweight


********************************************************************************
* STEP 10 — Save final dataset
********************************************************************************

save "$OUTPUT/final_data/fiscal_data.dta", replace





