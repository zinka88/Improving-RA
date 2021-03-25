# Code for "Improving the Performance of Risk Adjustment Systems: Constrained Regressions, Reinsurance, and Variable Selection"

# Summary
This set of programs predict total spending (or spending including reinsurance) using different sets of input variables and types of constraints/penalties. It outputs predicted values for each scenario, which can be used
to summarize performance across estimation methods.

# Programs
- run\_analysis.R - run analysis programs. Calls:
  - xfold\_regs.R - run x-fold crossvalidation (in parallel) for each estimation method.
    - screener.R 
    - helper\_functions.R  

# Data
The programs use the simulated data found in the "data" folder. This simulated data contains information on individual sex$\times$5-year age buckets, health condition categories (HCCs), drug-related condition categories (RXCs), four cchronic condition groups (cancer, diab, heart, mental), annual health spending (totpay), and annual health spending with reinsurance included (totpay\_r).

# Output
Each output dataset contains the predicted outcomes for the various methods:
- pred\_ols\_og: original risk adjustment formula predicting total spending (totpay) given inputs 
- pred\_ols: risk adjustment formula predicting spending given inputs, with reinsurance payments included 
- pred\_constraint: risk adjustment formula constraining predicted group spend = mean group spend
- pred\_constraint2: risk adjustment formula constraining predicted group spend to levels to preset predictive ratios
- pred\_penaltymixed: risk adjustment formula penalizing misprediction of groups.

The output also includes indictors for membership in one of the four chronic condition groups (cancer, diab, heart, mental) that were used in the constraints and penalties.


