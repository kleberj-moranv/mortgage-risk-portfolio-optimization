# Mortgage Risk Assessment and Portfolio Optimization

## Overview

This project develops an analytical framework for mortgage credit approval decisioning using 2025 Home Mortgage Disclosure Act (HMDA) data from Virginia. The project combines SQL, Python, statistical analysis, machine learning, and integer linear programming to examine mortgage denial patterns and evaluate how predictive risk estimates can support portfolio level capital allocation.

The analysis has three main components. First, descriptive and statistical analysis is used to identify financial and applicant characteristics associated with mortgage denial. Second, ensemble machine learning models are compared to predict the lender's observed approval or denial decision. Third, predicted denial probabilities are incorporated into an Integer Linear Programming (ILP) model that allocates capital while considering risk exposure, lending capacity, and portfolio diversification constraints.

An important limitation of the project is that HMDA records the lender's decision at the application stage rather than subsequent loan performance. Therefore, the predictive models estimate the probability of application denial, not the probability of borrower default.

## Business Problem

Mortgage underwriting often relies on fixed decision rules based on financial measures such as debt to income (DTI) and loan to value ratios. While these rules provide a consistent framework, they may not capture the interaction between multiple applicant and loan characteristics.

The project examines whether a data driven approach can provide more flexible risk assessment and support portfolio allocation decisions. The main business question is how a financial institution could allocate its available lending capital while maintaining a defined level of denial risk and operational constraints.

The project therefore connects predictive analytics with prescriptive analytics:

**Applicant and loan characteristics → Denial probability → Portfolio optimization → Capital allocation**

## Research Questions

The project addressed three main research questions:

1. How accurately can ensemble machine learning models predict mortgage denial decisions?

2. Are DTI and combined loan to value (CLTV) statistically significant drivers of mortgage application denial?

3. How does an Integer Linear Programming capital allocation approach compare with a static underwriting rule while maintaining a defined aggregate denial risk threshold?

## Dataset

The analysis uses 2025 HMDA data for Virginia.

The main data sources included:

* **HMDA Loan/Application Register (LAR):** individual mortgage application and loan information.
* **Institution Panel:** lender identification and institutional information.
* **Census demographic data:** area level income information used to calculate relative applicant income.

The initial HMDA LAR contained 397,846 records across 99 fields. After filtering to originated and denied applications and completing the data preparation process, the main analytical dataset contained 257,439 applications.

HMDA data are publicly available through the CFPB and FFIEC HMDA platforms.

## Data Preparation and ETL

The original raw HMDA files contained mixed data types, missing values, categorical codes, and text based ranges. A Python ETL pipeline was developed using pandas and SQLAlchemy to prepare the data before loading it into MySQL.

The main preparation steps included:

* Converting DTI ranges into numeric values using bucket midpoints.
* Converting CLTV values into numeric fields.
* Handling missing DTI, CLTV, and income values.
* Creating log transformed income and loan amount variables.
* Imputing missing interest rates using a DTI and CLTV based rule.
* Flagging imputed interest rate values.
* Linking applications to census tract income information.
* Creating an income to tract income ratio.
* Creating variables required for the optimization model.
* Identifying and flagging extreme loan amount and CLTV observations.
* Loading the cleaned data into MySQL.

The SQL database was then used for additional aggregations examining lender variation, geographic patterns, risk segments, and operational measures.

## Exploratory and Statistical Analysis

The exploratory analysis examined the relationship between mortgage denial and several financial and applicant characteristics.

The main variables of interest included:

* Debt to income ratio (DTI)
* Combined loan to value ratio (CLTV)
* Applicant income
* Income relative to census tract income
* Loan amount
* Loan purpose
* Loan type
* Occupancy type
* Applicant demographics
* Lending institution

The analysis identified substantial variation in denial rates across DTI categories and lending institutions. DTI showed a particularly strong descriptive relationship with denial outcomes, with denial rates increasing in the higher DTI ranges.

A DTI and CLTV interaction analysis also showed that denial rates varied across combinations of the two financial ratios, supporting the need to consider multiple characteristics rather than relying on a single threshold.

A logistic regression model was used to estimate the statistical association between financial and applicant characteristics and the observed denial decision.

The results showed that:

* DTI was positively associated with denial, with an odds ratio of **1.060** and p < .001.
* CLTV was positively associated with denial, with an odds ratio of **1.004** and p < .001.
* Higher log income was associated with lower denial odds.
* Loan purpose and occupancy type also showed substantial associations with denial.
* Some demographic variables showed statistically significant associations with denial after controlling for other variables.

Importantly, these results describe statistical associations within the dataset and should not be interpreted as evidence of causal mechanisms or discriminatory intent.

## Predictive Modeling

Three ensemble classification models were compared:

* Random Forest
* XGBoost
* LightGBM

The modeling pipeline used:

* An 80/20 stratified train test split.
* SMOTE applied only within the training pipeline.
* Median imputation for numeric variables.
* One hot encoding for categorical variables.
* A held out test set for final model evaluation.

### Model Results

| Model         | ROC AUC | Precision | Recall |    F1 |
| ------------- | ------: | --------: | -----: | ----: |
| LightGBM      |   0.862 |     0.810 |  0.501 | 0.619 |
| XGBoost       |   0.858 |     0.803 |  0.496 | 0.613 |
| Random Forest |   0.841 |     0.726 |  0.505 | 0.595 |

LightGBM produced the highest ROC AUC and was selected for downstream portfolio scoring.

The model showed a clear precision and recall trade off. Its precision for the denied class was approximately 0.81, while recall was approximately 0.50, meaning that the model identified only about half of the observed denied applications at the default classification threshold.

Feature importance showed that **CLTV and DTI were the two most influential predictors** in the LightGBM model. Other variables, including loan purpose, lien status, and loan type, also contributed predictive information.

Demographic variables were retained for fairness monitoring and analysis rather than being treated as appropriate automated credit allocation inputs.

## Portfolio Optimization

The predictive model was connected to a prescriptive Integer Linear Programming model using PuLP and the CBC solver.

The optimization model used predicted denial probabilities together with loan level financial information to determine which applications should be included in the optimized portfolio.

The model considered four main constraints:

1. **Capital budget:** approved loan amounts could not exceed the available lending pool.

2. **Portfolio risk:** aggregate denial risk had to remain below the team's 3.5% risk threshold.

3. **Labor capacity:** manual review requirements for borderline applications were constrained by available underwriting capacity.

4. **High DTI concentration:** loans with DTI above 45% could not exceed 15% of approved capital.

The 3.5% and 15% thresholds were **team defined assumptions for the optimization scenario**, not external regulatory requirements.

## Optimization Results

For computational tractability, the ILP was evaluated using a sample of 5,000 applications and a capital budget equal to 50% of the sample's requested loan volume.

| Metric                | Static Benchmark | ILP Optimized |
| --------------------- | ---------------: | ------------: |
| Approved Loans        |            2,687 |         1,821 |
| Approved Capital      |         $825.70M |      $911.85M |
| Net Portfolio Yield   |          $17.39M |       $41.72M |
| Aggregate Denial Risk |            3.68% |         1.59% |

The optimized portfolio approved fewer applications but allocated more total capital. Under the assumptions used in the model, it also produced substantially higher net portfolio yield while reducing the aggregate denial risk ratio below the team's 3.5% target.

These results should be interpreted as an optimization scenario rather than a validated portfolio forecast because the model was evaluated on a 5,000 application sample and several optimization parameters were defined by the project team.

## Sensitivity Analysis

Additional what if analysis was used to examine how the portfolio responds to changes in operational constraints.

The sensitivity analysis considered:

* Risk appetite limits.
* Underwriting labor capacity.
* Targeted allocation requirements for low and moderate income areas.

One finding was that reducing review hour capacity by 25% and 50% did not materially change net portfolio yield at the tested sample scale. This suggests that capital and risk constraints were binding before labor capacity under the assumptions used in the model.

The targeted low and moderate income allocation scenario produced a substantial reduction in modeled net portfolio yield under the tested parameters, illustrating the financial trade off between portfolio objectives and allocation requirements.

## Fairness and Model Risk

Fairness was considered as part of both the predictive and statistical analysis.

Applicant race appeared among the top 15 features in the LightGBM split importance results, while the logistic regression showed statistically significant associations for some race categories after controlling for financial and loan characteristics.

These findings should be interpreted carefully. They identify statistical patterns that warrant additional fairness analysis, but they do not establish why the differences occur or demonstrate discriminatory intent.

The project therefore recommends additional analysis such as SHAP based feature attribution and group level fairness evaluation before any real world deployment.

The project also recognizes that demographic variables should not be treated as straightforward credit allocation inputs simply because they improve predictive performance.

## Key Findings

The main findings of the project were:

* DTI and CLTV were statistically significant predictors of the observed mortgage denial decision.
* LightGBM achieved the highest ROC AUC among the three tested ensemble models.
* DTI and CLTV were also the most influential features in the LightGBM model.
* The selected model had high precision for the denied class but only moderate recall.
* The ILP scenario produced higher modeled net portfolio yield while reducing aggregate denial risk relative to the static benchmark.
* The optimization results demonstrate how predictive analytics can be connected to capital allocation decisions.
* Sensitivity analysis showed that the effect of operational constraints depends on which constraints are binding under the selected assumptions.
* Demographic patterns identified in the models should be treated as fairness monitoring signals rather than causal explanations.

## Limitations

Several limitations should be considered when interpreting the results:

* HMDA records lender decisions but does not provide subsequent borrower default outcomes.
* The predictive models therefore estimate denial probability rather than default probability.
* The ILP was evaluated on a 5,000 application sample rather than the full analytical dataset.
* Review hours, the rejection cost factor, and the 15% and 3.5% policy thresholds were team defined assumptions.
* The model's denied class recall was only around 0.50 at the default classification threshold.
* Statistical associations cannot be interpreted as causal effects.
* A full fairness audit was outside the scope of the completed analysis.

## Tools and Technologies

* **Python:** pandas, NumPy, scikit learn, XGBoost, LightGBM, statsmodels, PuLP
* **SQL:** MySQL
* **Visualization:** Tableau
* **Optimization:** Integer Linear Programming, CBC solver
* **Data Processing:** pandas, SQLAlchemy
* **Documentation and Presentation:** Jupyter Notebook, PowerPoint

## My Contribution

This was a group project. My main contributions focused on the business context, analytical quality control, and interpretation of the results.

I contributed to:

* Researching and defining the business context and motivation for the analysis.
* Reviewing the analytical workflow and supporting code quality control.
* Interpreting predictive model performance and comparing model metrics.
* Interpreting the statistical testing and logistic regression results.
* Reviewing and interpreting the ILP optimization results.
* Connecting analytical findings with operational and managerial implications.
* Contributing to the interpretation of fairness considerations and model limitations.

I did not independently implement the predictive models or the optimization model. The technical modeling and optimization components were developed collaboratively by the project team.

## Project Outputs

The project produced:

* Jupyter notebooks documenting the data preparation and modeling workflow.
* SQL scripts for database creation and analytical queries.
* Tableau dashboards for exploratory and model informed visualization.
* Predictive classification models.
* Logistic regression analysis.
* Integer Linear Programming optimization.
* Sensitivity and what if analysis.
* Written analytical report.
* Presentation slides and video presentation.

## Data Availability

The analysis uses publicly available 2025 HMDA data for Virginia. The raw and cleaned datasets are not included in this repository.

The repository focuses on the analytical workflow, documentation, selected code, and visual outputs. Dataset access and reproducibility should follow the applicable HMDA data access and use requirements.

## Project Type

**Group academic project**

## Author

**Kleber Moran**

Master of Data Analytics
University of Niagara Falls Canada
