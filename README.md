\# 📊 MEASURING THE DISTRIBUTIVE IMPACT OF INDIRECT TAXES IN CÔTE D’IVOIRE  

\### CEQ-based analysis using EHCVM 2021



\---



\## Overview



This project estimates the \*\*distributional incidence of indirect taxes (VAT)\*\* in Côte d’Ivoire using detailed household consumption data from the \*\*EHCVM 2021 survey\*\*.



The objective is to identify \*\*who effectively bears the burden of VAT\*\*, both in absolute terms and relative to total consumption, and to assess whether the tax system is \*\*progressive, proportional, or regressive\*\* across the distribution of living standards.



The analysis is designed as a \*\*first-order fiscal incidence exercise\*\*, providing a transparent and reproducible framework adapted to data-constrained environments.



\---



\##  Conceptual Framework



The analysis follows a \*\*CEQ-inspired (Commitment to Equity) framework\*\*, adapted to the Ivorian context and available data.



In a standard CEQ setting, multiple income concepts are compared (market income, disposable income, consumable income, final income). Due to data limitations, this project focuses on the transition from observed consumption to a simulated post-tax measure.



\### Core identity



\*\*Consumable Income = Total Consumption − Indirect Taxes\*\*



This allows us to isolate the \*\*direct effect of consumption taxes\*\* on household welfare.



\---



\##  Methodology



The empirical strategy relies on a \*\*bottom-up microsimulation approach\*\*:



1\. \*\*Consumption aggregation\*\*  

&#x20;  Household-level consumption is constructed from detailed product-level expenditures.



2\. \*\*Tax mapping\*\*  

&#x20;  Each product (`codpr`) is assigned a fiscal treatment based on the VAT system:

&#x20;  - Exempt  

&#x20;  - Reduced rate  

&#x20;  - Standard rate  

&#x20;  - Other categories where applicable  



3\. \*\*Tax imputation\*\*  

&#x20;  VAT is simulated at the product level and aggregated at the household level.



4\. \*\*Welfare comparison\*\*  

&#x20;  Pre-tax consumption is compared to simulated consumable income.



5\. \*\*Distributional analysis\*\*  

&#x20;  Results are analyzed across deciles of consumption using:

&#x20;  - Effective tax rates  

&#x20;  - Concentration curves  

&#x20;  - Progressivity indices  



\---



\##  Data



\- Source: \*\*EHCVM 2021 (Côte d’Ivoire)\*\*  

\- Unit of observation: \*\*Household × product\*\*  

\- Unit of analysis: \*\*Household\*\*



\### Key variables



\- `codpr` → product identifier  

\- `modep` → acquisition mode  

\- `depan` → annual expenditure  

\- `hhweight` → sampling weight  



\---



\##  Informality and Effective Taxation



A key challenge in developing economies is that \*\*not all transactions are effectively taxed\*\*, due to informality.



To address this, the analysis incorporates \*\*heterogeneous effective taxation scenarios\*\* based on the \*\*Informality Engel Curve (IEC)\*\* framework.



\### Scenario 1 — Strict (α = 1)



\- Full taxation of all eligible consumption  

\- Represents a \*\*theoretical upper bound\*\*  



\### Scenario 2 — CEI × location



\- α varies by:

&#x20; - COICOP category  

&#x20; - Urban vs rural location  



\- Captures structural differences in market access  



\### Scenario 3 — CEI × decile



\- α increases with consumption level  

\- Reflects that \*\*richer households are more likely to purchase in formal markets\*\*



These scenarios allow testing how \*\*informality affects distributional outcomes\*\*, not just aggregate tax levels.



\---



\##  Outputs



The project produces a comprehensive set of distributional indicators:



\- Effective VAT rates by decile  

\- Tax burden (absolute and relative)  

\- Concentration curves  

\- Gini coefficients (pre- and post-tax)  

\- Kakwani index of progressivity  

\- Sensitivity and robustness analysis  



\---



\##  Key Assumptions



The analysis relies on several standard assumptions:



\### 1. Full pass-through

VAT is assumed to be fully reflected in consumer prices.



\### 2. Consumption as welfare proxy

Consumption is used as a proxy for permanent income.



\### 3. Partial equilibrium

No indirect effects via production chains or general equilibrium adjustments.



Results should therefore be interpreted as a \*\*first-order approximation of tax incidence\*\*.



\---



\## Limitations



\- No direct taxes or social transfers  

\- No behavioral responses (price or demand adjustments)  

\- No input-output transmission effects  

\- Informality modeled through scenarios rather than observed directly  



These limitations are explicitly acknowledged as part of a \*\*transparent and progressive research strategy\*\*.



\---



\## Research Design



This project is conceived as a \*\*cumulative research program\*\*:



1\. Construct taxable consumption and VAT incidence  

2\. Integrate administrative fiscal data  

3\. Improve modeling of informality  

4\. Extend toward a full CEQ analysis  



\---



\## References



\- Bachas, P., Gadenne, L., \& Jensen, A. (2024). \*Informality, Consumption Taxes, and Redistribution\*  

\- Lustig, N. (2018). \*Commitment to Equity Handbook\*  

\- World Bank (2024). \*Urban Informality in Sub-Saharan Africa (WPS 10703)\*  

\- UNECA (2019). \*Economic Report on Africa\*  



\---



\## Reproducibility



The repository is structured to ensure reproducibility:







\---



\##  Author



\*\*Armand Djaha, M.Sc.\*\*  

Applied Economist | Research 



ANStat — Cellule d’Analyses Économiques (CAE)  



Côte d’Ivoire / Canada  

armandjaha@gmail.com  

https://www.linkedin.com/in/armand-djaha-m-sc-108119186  



\---



\## Status



> Working paper — April 2026  

> Final project (ANStat)



\---



\## Conclusion



This project provides a \*\*transparent, reproducible, and policy-relevant framework\*\* for analyzing VAT incidence in Côte d’Ivoire.



It offers a robust starting point for \*\*evidence-based fiscal policy analysis\*\* and can be extended to other countries using harmonized EHCVM data.

