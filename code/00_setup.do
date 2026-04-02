********************************************************************************
* IMPORTANT NOTE:
*
* This file (00_setup.do) must be executed from the project root directory.
*
* Recommended usage:
*   - Open Stata directly in the project root folder, OR
*   - Set the working directory manually using the "cd" command before running.
*
* Alternatively, opening and running this file directly in Stata will set up
* the correct project paths and prevent path-related errors in the code.
*
* This ensures that all relative paths used in the project remain valid and
* the code does not break across different machines or environments.
********************************************************************************
clear all
set more off
set varabbrev off

* Vérification robuste
capture confirm file "code/00_master.do"

if _rc != 0 {
    di as error "--- wrong work folder"
    di as error "--- Run Stata from the project's root folder"
    exit 198
}

* folder
global ROOT = c(pwd)

global DATA   "$ROOT/data/EHCVM/EHCVM2122"
global CODE   "$ROOT/code"
global OUTPUT "$ROOT/output"
global LOGS   "$OUTPUT/logs"
global TABLES "$OUTPUT/tables"
global FIGS   "$OUTPUT/figures"

dir DATA/EHCVM/EHCVM2122/

* gen inexistant folder
cap mkdir "$OUTPUT"
cap mkdir "$LOGS"
cap mkdir "$TABLES"
cap mkdir "$FIGS"

* Log
cap log close
log using "$LOGS/master.log", replace text