# Did COVID-19 Change the Income Elasticity of Health Expenditure in OECD Countries?

**A panel data analysis of 38 OECD countries, 2000–2024**

[![R](https://img.shields.io/badge/R-4.3%2B-blue?logo=r)](https://www.r-project.org/)
[![Method](https://img.shields.io/badge/method-Two--way%20Fixed%20Effects-brightgreen)](#)
[![Data](https://img.shields.io/badge/data-OECD%20Health%20Statistics-orange)](https://data-explorer.oecd.org/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](#license)

---

## TL;DR

- **Question:** Did the COVID-19 pandemic structurally change how OECD health spending responds to income?
- **Method:** Two-way fixed-effects panel regression (country + year FE) with a `log(GDP) × Post-COVID` interaction term, clustered SEs at country level. Three robustness checks: lagged GDP, dropping the aging control, and excluding 2020.
- **Data:** 38 OECD countries × 25 years = 913 country-year observations, sourced from OECD Health Statistics.
- **Finding:** Health expenditure behaves as a **necessity good** (elasticity ≈ 0.90 pre-COVID, ≈ 0.82 post-COVID). The post-pandemic decline is **not statistically significant** — the level of spending shifted up, but the *relationship* with income was preserved.

---

## Why this project matters

Health spending across OECD countries has risen from 8.8% of GDP pre-pandemic to 9.3% in 2024, with 16 countries now exceeding the 10% threshold. Whether health expenditure is a **luxury** (elasticity > 1) or a **necessity** (elasticity < 1) directly affects how public health systems should be financed as economies grow.

Existing literature ends before 2020. This project provides the **first cross-country panel estimate that incorporates the full post-COVID period (2020–2024)** for all 38 OECD member states, isolating whether the pandemic marked a structural break or a one-time level shift.

---

## Methodology at a glance

**Baseline specification** (log-log, two-way fixed effects):
