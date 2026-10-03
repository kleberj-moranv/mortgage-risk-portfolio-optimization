USE cleaned_hmda_mortgage;

/* Bank-Level Executive Summary
Evaluates underwriting outcomes and risk profile per financial institution. 
*/
SELECT 
    i.bank_name,
    h.lei,
    COUNT(*) AS total_applications,
    ROUND(AVG(h.target_denied) * 100.0, 2) AS denial_rate_pct,
    ROUND(SUM(h.loan_amount), 2) AS total_volume,
    ROUND(AVG(h.loan_amount), 2) AS avg_loan_amount,
    ROUND(AVG(h.dti_clean), 2) AS avg_dti,
    ROUND(AVG(h.cltv_clean), 2) AS avg_cltv,
    ROUND(AVG(h.interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(h.LGD), 4) AS avg_lgd,
    ROUND(AVG(h.is_high_dti) * 100.0, 2) AS high_dti_share_pct
FROM hmda_lar_2025_cleaned h
JOIN institution_panel_cleaned i 
    ON h.lei = i.lei
GROUP BY i.bank_name, h.lei
ORDER BY total_applications DESC;

/* High-DTI Risk Exposure & Pricing Disparity
Aggregated risk metrics and operational effort between standard and high debt-to-income applicants 
*/
SELECT 
    is_high_dti,
    COUNT(*) AS total_loans,
    ROUND(AVG(target_denied) * 100.0, 2) AS denial_rate_pct,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(AVG(imputed_interest_rate), 2) AS avg_imputed_rate,
    ROUND(AVG("LGD"), 4) AS avg_lgd,
    ROUND(AVG(review_hours), 2) AS avg_underwriting_review_hours
FROM hmda_lar_2025_cleaned
GROUP BY is_high_dti;

/*Neighborhood & Census Tract Analysis
Aggregates lending metrics by census_tract, this can be used for tableu mapping.
*/
SELECT 
    census_tract,
    COUNT(*) AS application_count,
    ROUND(AVG(income_to_tract_ratio), 2) AS avg_income_tract_ratio,
    ROUND(AVG(target_denied) * 100.0, 2) AS tract_denial_rate_pct,
    ROUND(AVG(loan_amount), 2) AS avg_tract_loan_amount,
    ROUND(AVG(interest_rate), 2) AS avg_tract_rate
FROM hmda_lar_2025_cleaned
GROUP BY census_tract
HAVING COUNT(*) >= 5
ORDER BY application_count DESC;

/* Underwriting Operational Efficiency vs. Decision Outcome
Measures underwriting effort (review_hours) and expected loss given default (LGD) segmented by loan approval status.
*/
SELECT 
    target_denied,
    COUNT(*) AS total_cases,
    ROUND(AVG(review_hours), 2) AS avg_review_hours,
    ROUND(AVG(dti_clean), 2) AS avg_dti,
    ROUND(AVG(cltv_clean), 2) AS avg_cltv,
    ROUND(AVG("LGD"), 4) AS avg_lgd
FROM hmda_lar_2025_cleaned
GROUP BY target_denied;
