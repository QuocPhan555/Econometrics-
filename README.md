# Did COVID-19 Change the Income Elasticity of Health Expenditure in OECD Countries?

**A panel data analysis of 38 OECD countries, 2000–2024**

[![R](https://img.shields.io/badge/R-4.3%2B-blue?logo=r)](https://www.r-project.org/)
[![Method](https://img.shields.io/badge/method-Two--way%20Fixed%20Effects-brightgreen)](#)
[![Data](https://img.shields.io/badge/data-OECD%20Health%20Statistics-orange)](https://data-explorer.oecd.org/)
[![License](https://img.shields.io/badge/license-MIT-lightgrey)](#license)

---

## What this project is

An empirical econometrics study that estimates the **income elasticity of health expenditure** before and after COVID-19, using a **two-way fixed-effects panel model** with an interaction term to separate the pre- and post-pandemic responses.

The full academic write-up (literature review, methodology, discussion) is in [`Project_Econometric_Quoc_Phan_Submission.pdf`](Project_Econometric_Quoc_Phan_Submission.pdf); this README is the short version.

## Why it matters

- OECD health spending rose from **8.8% of GDP pre-pandemic to 9.3% in 2024** — 16 countries now spend over 10%.
- Whether health spending is a **luxury** (elasticity > 1) or a **necessity** (elasticity < 1) determines how public health systems should be financed as economies grow.
- Existing literature ends before 2020. This project is the **first cross-country panel estimate covering the full post-COVID period** across all 38 OECD member states, testing whether the pandemic marked a structural break or a one-time level shift.

## What I did

1. **Built a country-year panel** of 913 observations from three OECD Health Statistics datasets (health expenditure, GDP per capita, share aged 65+).
2. **Estimated a two-way fixed-effects log-log model** with a `log(GDP) × Post-COVID` interaction to isolate whether the elasticity shifted after 2020.
3. **Tested the post-COVID elasticity** against zero using a Wald test on the linear restriction `β₁ + β₂ = 0`.
4. **Ran three robustness checks** — lagged GDP (reverse causality), dropping the age control (omitted variable sensitivity), excluding 2020 (outlier year).

## How I did it

- **Cleaned and merged** three raw OECD CSVs on country + year with `dplyr`, filtering GDP to the long-run real series for consistent PPP comparison.
- **Chose a log-log specification** so coefficients read directly as elasticities and heteroskedasticity from income-level differences is reduced.
- **Applied country + year fixed effects** to remove time-invariant institutional differences and global shocks, so identification comes from within-country variation over time.
- **Clustered standard errors at the country level** to handle serial correlation across years within the same country.
- **Selected controls by causal reasoning, not p-values** — kept the aging variable as a genuine confounder; deliberately excluded unemployment (a mediator) and Debt/GDP (denominator overlap) to avoid bad-control bias, following Angrist & Pischke (2009).

## Key finding

Health expenditure behaves as a **necessity good** in every specification (elasticity ≈ 0.90 pre-COVID, ≈ 0.82 post-COVID). The post-pandemic drop is **not statistically significant** — spending shifted to a permanently higher level, but its relationship with income held steady.

| Sample | Pre-COVID elasticity `log(GDP)` | Post-COVID change `log(GDP) × Post-COVID` | Post-COVID elasticity |
|---|---|---|---|
| Full panel (2000–2024) | 0.897*** | −0.082 | 0.815 |
| Lagged GDP | 0.885*** | −0.077 | 0.808 |
| Excluding 2020 | 0.905*** | −0.089 | 0.816 |

*\*\*\* p < 0.001. Country-clustered standard errors.*

## How to use it

```r
# 1. Install packages
install.packages(c("dplyr", "plm", "fixest", "ggplot2",
                   "car", "sandwich", "lmtest", "modelsummary"))

# 2. Clone this repo and open mainscript_project.R
# 3. Set the working directory to your local repo path
setwd("path/to/this/repo")

# 4. Run the full pipeline
source("mainscript_project.R")
```

Runtime: ~10 seconds. Data sources are in `datain/` and downloaded from the [OECD Data Explorer](https://data-explorer.oecd.org/).

## Skills demonstrated

- **Panel econometrics** — two-way fixed effects, clustered standard errors, interaction terms, Wald / linear-hypothesis testing
- **Causal inference reasoning** — confounder vs. mediator vs. bad control; reverse-causality diagnosis via lagged regressors
- **Robustness discipline** — three independent checks targeting different threats to identification
- **R programming** — `dplyr` pipelines, `fixest::feols` for high-dimensional FE, `plm` for panel structures, `modelsummary` for publication-quality tables, `ggplot2` for descriptive plots
- **Academic writing** — structured empirical paper with literature review, methods justification, and honest limitations


