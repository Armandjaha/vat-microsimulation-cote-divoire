# \### MEASURING THE DISTRIBUTIVE IMPACT OF INDIRECT TAXES IN COTE D'IVOIRE

# \---

# 

# \##  Overview

# 

# This project estimates the \*\*distributional incidence of indirect taxes (VAT)\*\* in Côte d’Ivoire using household consumption data from \*\*EHCVM 2021\*\*.

# 

# The objective is to identify \*\*who pays VAT\*\*, in absolute and relative terms, and to assess whether the system is \*\*progressive, proportional, or regressive\*\*.

# 

# \---

# 

# \##  Methodology

# 

# The analysis follows a \*\*CEQ-inspired framework\*\*, adapted to data constraints typical of developing economies.

# 

# \### Core identity:

# 

# Consumable Income = Total Consumption − Indirect Taxes

# 

# \### Key features:

# 

# \- Consumption used as proxy for pre-tax welfare

# \- Product-level VAT imputation (codpr → fiscal category)

# \- Household-level aggregation using survey weights

# \- Static \*\*first-order incidence analysis\*\*

# 

# \---

# 

# \##  Data



# \- Source: EHCVM 2021 (Côte d’Ivoire)

# \- Unit of analysis: Household x product

# 

# \### Key variables:

# \- `codpr` → product code

# \- `modep` → acquisition mode

# \- `depan` → annual expenditure

# \- `hhweight` → survey weight

# 

# \---

# 

# \## Scenarios (Informality)

# 

# To account for informality, three scenarios are implemented:

# 

# \- \*\*Strict (α = 1)\*\*

# &#x20; Full taxation of all eligible consumption (upper bound)

# 

# \- \*\*S2 — CEI × location\*\*

# &#x20; α varies by COICOP category and urban/rural status

# 

# \- \*\*S3 — CEI × decile\*\*

# &#x20; α increases with consumption level (Engel curve of informality)

# 

# 

# \##  Outputs

# 

# \- Effective VAT rates by decile

# \- Tax burden (absolute and relative)

# \- Concentration curves

# \- Gini and Kakwani indices

# \- Robustness analysis

# 

# 

# \## Key Assumptions

# 

# \- \*\*Full pass-through\*\* of VAT to consumer prices

# \- Consumption as proxy for welfare

# \- No indirect effects (input-output, general equilibrium)

# 

# So results should be interpreted as a \*\*first-order approximation\*\*

# 

# 

# \## Limitations

# 

# \- No direct taxes or transfers

# \- No behavioral responses

# \- No production-side effects

# \- Informality approximated through scenarios

# 

# \---

# 

# \## Research Design

# 

# This project is part of a progressive research agenda :

# 

# 1\. Estimate VAT incidence from consumption

# 2\. Integrate administrative fiscal data

# 3\. Refine informality modeling

# 4\. Extend toward full CEQ analysis

# 

# 

# \## References

# 

# \- Bachas, Gadenne \& Jensen (2024) — \*Informality, Consumption Taxes, and Redistribution\*

# \- Lustig (2018) — CEQ Handbook

# \- World Bank (2024) — Urban Informality (WPS 10703)

# \- UNECA (2019) — Economic Report on Africa

# 

# \---

# 

# \## Reproducibility







\##  Author



ANStat

Cellule d'Analyses Economiques (CAE)

\*\*Armand Djaha, M.Sc.\*\*

Applied Economist | Statistical Analyst



Côte d’Ivoire / Canada

armandjaha@gmail.com

https://www.linkedin.com/in/armand-djaha-m-sc-108119186



\---



\## Status



> Working paper — April 2026  

> Final project (ANStat)



\---



\## Conclusion



This project provides a transparent, reproducible and policy-relevant framework to analyze VAT incidence in Côte d’Ivoire, and can be extended to other UEMOA countries using EHCVM data.

