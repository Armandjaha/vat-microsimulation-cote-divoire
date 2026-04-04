********************************************************************************
* 02_mapping_tax_clean.do
*
* OBJECTIVE:
* Build a clean and auditable VAT mapping by product code (codpr),
* starting from:
*   (1) an official Excel mapping imported from the CGI 2026 VAT table
*   (2) a manual completion file for missing products
*
* FINAL OUTPUT:
* A final product-level VAT mapping file ready to merge with consumption data.
*
* CORE PRINCIPLES:
* - codpr is the ONLY merge key
* - official imported VAT and manual VAT are kept distinct
* - manual completion is used only when official VAT is missing
* - source priority is explicit and reproducible
*
* ECONOMIC INTERPRETATION:
* - r_vat_official: VAT rate imported from the official mapping
* - tva_manual: VAT rate manually assigned to unmapped products
* - r_vat_final: final VAT rate used in analysis
* - hors_champ: product outside VAT scope in the original official mapping
*
* NOTES:
* - VAT rates are stored as proportions: 0, 0.09, 0.18
* - manual VAT entered in Excel is assumed to be in percentage points: 0, 9, 18
********************************************************************************

clear all
set more off

********************************************************************************
* STEP 1 — Import official Excel VAT mapping
********************************************************************************
* Expected Excel file contains at least:
* - CODPR
* - ProduitService
* - TVAaprèsCGI2026envigueur

import excel ///
    "$DATA/TVA_CGI_2026_Cote_Ivoire_Final_m.xlsx", ///
    sheet("Sheet1") firstrow clear

********************************************************************************
* STEP 2 — Standardize variable names
********************************************************************************

rename CODPR                    codpr
rename ProduitService           produit
rename TVAaprèsCGI2026envigueur r_vat_raw


********************************************************************************
* STEP 3 — Handle "Hors champ"
********************************************************************************
* "Hors champ" means outside the VAT scope.
* We preserve this information with an indicator, but set the raw rate to 0
* so it can be converted numerically.

gen hors_champ = (trim(r_vat_raw) == "Hors champ")

replace r_vat_raw = "0" if trim(r_vat_raw) == "Hors champ"

********************************************************************************
* STEP 4 — Clean raw VAT rate string
********************************************************************************
* Remove %, *, spaces, then convert to numeric.

replace r_vat_raw = subinstr(r_vat_raw, "%", "", .)
replace r_vat_raw = subinstr(r_vat_raw, "*", "", .)
replace r_vat_raw = trim(r_vat_raw)

* Convert to numeric
destring r_vat_raw, replace force

* Convert from percent to proportion
gen r_vat_official = r_vat_raw / 100

drop r_vat_raw

********************************************************************************
* STEP 5 — Validate imported official VAT rates
********************************************************************************

di as text ">>> Summary of official VAT rates"
sum r_vat_official

di as text ">>> Distribution of official VAT rates"
tab r_vat_official

di as text ">>> Distribution of hors_champ indicator"
tab hors_champ


********************************************************************************
* STEP 6 — Check uniqueness of codpr in official mapping
********************************************************************************
* Each codpr should map to one unique official VAT profile.

duplicates report codpr

********************************************************************************
* STEP 7 — Keep only relevant variables from official mapping
********************************************************************************

keep codpr produit hors_champ r_vat_official

* Add explicit source
gen source = "official"

sort codpr produit
save "$OUTPUT/final_data/mapping_fiscal_official.dta", replace

di as result ">>> Official VAT mapping cleaned and saved"

********************************************************************************
* STEP 8 — Audit official mapping coverage against consumption data
********************************************************************************
* Goal: identify products present in conso_clean but absent from official mapping,
* and vice versa.

* Unique product list from consumption data
use "$OUTPUT/final_data/conso_clean.dta", clear

keep codpr
duplicates drop

tempfile conso_products
save `conso_products'

* Unique product list from official mapping
use "$OUTPUT/final_data/mapping_fiscal_official.dta", clear

keep codpr
duplicates drop

tempfile official_products
save `official_products'

* Compare coverage
use `conso_products', clear
merge 1:1 codpr using `official_products'

di as text ">>> Coverage audit: conso vs official mapping"
tab _merge

* _merge==1: product exists in conso but not in official mapping
* _merge==2: product exists in mapping but not in conso
* _merge==3: matched

********************************************************************************
* STEP 10 — Build manual completion file from unmatched products
********************************************************************************
* We keep both _merge==1 and _merge==2 for review.
* In practice, _merge==1 is the critical group for completion.

preserve
keep if _merge != 3
keep codpr
duplicates drop

* Recover product labels from codpr using value labels if needed
decode codpr, gen(produit)

* Manual completion fields
gen tva_manual = .
gen categorie  = ""
gen source     = "manual"
sort codpr 
save "$OUTPUT/final_data/mapping_manual_to_fill.dta", replace

export excel using "$OUTPUT/final_data/mapping_manual_to_fill_0.xlsx", ///
    firstrow(variables) replace
restore

di as result ">>> Manual completion file exported"

********************************************************************************
* STEP 11 — Import completed manual file
********************************************************************************
* At this stage, we manually filled mapping_manual_to_fill.xlsx
* especially the variable tva_manual with values such as 0, 9, 18.

import excel "$OUTPUT/final_data/mapping_manual_to_fill_completed.xlsx", ///
    firstrow clear

* Standardize again, just in case
replace produit = trim(produit)

capture confirm numeric variable codpr
if _rc {
    destring codpr, replace force
}

capture confirm numeric variable tva_manual
if _rc {
    destring tva_manual, replace force
}

* Validate manual VAT entries where provided
assert inlist(tva_manual, 0, 9, 18) if !missing(tva_manual)

save "$OUTPUT/final_data/mapping_manual_completed.dta", replace

di as result ">>> Manual completion file imported and saved"

********************************************************************************
* STEP 12 — Append official and manual mapping
********************************************************************************
* We append the two sources and then keep one record per codpr
* according to an explicit priority rule.

use "$OUTPUT/final_data/mapping_fiscal_official.dta", clear
append using "$OUTPUT/final_data/mapping_manual_completed.dta"

********************************************************************************
* STEP 13 — Create explicit priority rule
********************************************************************************
* Preference order:
*   1 = manual
*   2 = official
*
* Why?
* Because manual rows were specifically created to fill missing or problematic
* cases after the audit step.

gen priority = .
replace priority = 1 if source == "manual"
replace priority = 2 if source == "official"

assert !missing(priority)

sort codpr priority

* Keep first row within codpr according to priority
by codpr: keep if _n == 1

drop priority

********************************************************************************
* STEP 14 — Build final VAT rate
********************************************************************************
* Keep official and manual information separate.
* Final VAT = official VAT when available, otherwise manual VAT / 100.

gen r_vat_manual = tva_manual / 100 if !missing(tva_manual)

gen r_vat_final = r_vat_official
replace r_vat_final = r_vat_manual if missing(r_vat_final)

********************************************************************************
* STEP 15 — update of hors_champ logic
********************************************************************************
* hors_champ comes from official mapping only.
* For manual-only rows, hors_champ may be missing.
* We keep the original meaning strict:
* - hors_champ = 1 only if explicitly identified as such in official mapping
* - otherwise 0 for manual completed rows unless you want another rule

replace hors_champ = 0 if missing(hors_champ)

********************************************************************************
* STEP 16 — Validate final mapping
********************************************************************************

di as text ">>> Summary of final VAT rate"
sum r_vat_final

di as text ">>> Distribution of final VAT rate"
tab r_vat_final

* Final VAT rate must be non-missing and valid
*assert !missing(r_vat_final)
*assert inlist(r_vat_final, 0, 0.09, 0.18)

* codpr must now be unique
duplicates report codpr

********************************************************************************
* STEP 17 — Save final product-level mapping
********************************************************************************

keep codpr produit hors_champ r_vat_official tva_manual r_vat_manual ///
     r_vat_final source

sort codpr
save "$OUTPUT/final_data/mapping_fiscal_final.dta", replace

di as result ">>> Final VAT mapping saved successfully"

********************************************************************************
* STEP 18 — Merge final mapping into consumption data
********************************************************************************
* This is the final operational merge used for incidence analysis.

use "$OUTPUT/final_data/conso_clean.dta", clear

merge m:1 codpr using "$OUTPUT/final_data/mapping_fiscal_final.dta"

di as text ">>> Final merge results"
tab _merge

* Strong expectation:
* - _merge==1 should be 0
* - _merge==3 should cover all consumption observations
* - _merge==2 can exist and is harmless for final analysis

********************************************************************************
* STEP 19 — Diagnostics after merge
********************************************************************************

* Products in consumption still missing from mapping (should be zero)
count if _merge == 1
br codpr r_vat_final produit if _merge == 1

* Products in mapping not observed in conso (not a problem)
count if _merge == 2
br codpr r_vat_final produit if _merge == 2

********************************************************************************
* STEP 20 — keep only matched observations for analysis
********************************************************************************
keep if _merge == 3
drop _merge

********************************************************************************
* STEP 21 — LABELING DATASET
********************************************************************************

*-------------------------------
* 1. LABEL VARIABLES 
*-------------------------------

label variable country        "Country code"
label variable year           "Survey year"
label variable hhid           "Household unique identifier"
label variable vague          "Survey wave"
label variable grappe         "Sampling cluster"
label variable menage         "Household number within cluster"

label variable region         "Region of residence"
label variable milieu         "Area of residence (urban/rural)"

label variable hhweight       "Household sampling weight"

label variable codpr          "Product code (EHCVM nomenclature)"
label variable produit        "Product / Service label"

label variable inclus         "Included in final consumption aggregate"
label variable coicop         "COICOP classification"
label variable modep          "Mode of acquisition"

label variable depan          "Annual consumption expenditure (CFA)"
label variable log_depan      "Log of annual consumption expenditure"
label variable depan_w        "Winsorized consumption expenditure"

* VAT / fiscal variables
label variable hors_champ     "Out of VAT scope (1=yes, 0=no)"
label variable r_vat_official "Official VAT rate (CGI 2026)"
label variable tva_manual     "Manually assigned VAT rate (%)"
label variable r_vat_manual   "Manual VAT rate (proportion)"
label variable r_vat_final    "Final VAT rate used in analysis"

label variable source         "Source of VAT assignment (official/manual)"

*-------------------------------
* 1. LABEL VALUES 
*-------------------------------
* Inclus
label define inclus_lbl 0 "No" 1 "Yes"
label values inclus inclus_lbl

* Source
label define source_lbl 1 "Official" 2 "Manual"
encode source, gen(source_num)
label values source_num source_lbl

/*
* final VAT
gen vat_cat = round(r_vat_final*100)

replace vat_cat = 0  if vat_cat==0
replace vat_cat = 9  if vat_cat==9
replace vat_cat = 18 if vat_cat==18

label define vat_cat_lbl 0 "Exempt (0%)" 1"Reduced(9%)" 2"Standard (18%)"

label values vat_cat vat_cat_lbl
label variable vat_cat "VAT category"
*/


format r_vat_official %9.2f
format r_vat_manual   %9.2f
format r_vat_final    %9.2f

format depan %15.0fc
format depan_w %15.0fc




********************************************************************************
* STEP 22 - Saving
********************************************************************************


save "OUTPUT/final_data/conso_clean", replace
di as result ">>> Dataset labeled and ready for analysis"


********************************************************************************
* END
********************************************************************************

