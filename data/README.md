# Data

The project uses 2025 Home Mortgage Disclosure Act (HMDA) data for Virginia, together with institution level information used during the analysis.

The raw and cleaned datasets are **not included in this repository**. The project data were used for academic analysis and contain detailed mortgage application records, so the repository focuses on the analytical workflow, code, and selected visual outputs rather than redistributing the datasets.

## Data Sources

The main datasets used in the project were:

* **HMDA Loan/Application Register (LAR):** mortgage application and loan level information.
* **Institution Panel:** lender and financial institution information.

Additional census tract income information was used to create relative income measures during the data preparation process.

The datasets can be obtained from the official HMDA data sources, subject to their current access and use conditions.

## Files Used in the Analysis

The main analytical files referenced in the project were:

```text
hmda_lar_2025_cleaned.csv
institution_panel_cleaned.csv
```

These files are intentionally not included in this repository.

## Reproducibility

The notebooks and SQL scripts document the main data preparation and analytical workflow. To reproduce the analysis, the corresponding source datasets would need to be obtained separately and placed in this folder before running the relevant code.

**Note:** File names and paths in the notebooks may need to be adjusted depending on where the source datasets are stored locally.
