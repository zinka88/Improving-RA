# Code for "Improving the Performance of Risk Adjustment Systems: Constrained Regressions, Reinsurance, and Variable Selection"

# Summary
This set of programs predicts total spending (or spending including reinsurance) using different sets of input variables and types of constraints/penalties. It outputs predicted values for each scenario, which can be used
to summarize performance across estimation methods.

# Programs
- run\_analysis.R - runs analysis programs. Calls:
  - xfold\_regs.R - runs x-fold crossvalidation (in parallel processes) to risk adjustment using constrained an penalized methods. Calls:
    - screener.R 
    - helper\_functions.R  

# Data
The programs uses the simulated data found in the "data" folder. This simulated data contains information on individual sex x 5-year age buckets, health conditions categories (HCCs), drug-related condition categories (RXCs), annual health spending (totpay), and annual health spending with reinsurance included (totpay\_r).

# Output
Each output dataset contains the predicted outcomes for the various methods:
- pred\_ols\_og: original risk adjustment formula predicting total spending (totpay) given inputs 
- pred\_ols: risk adjustment formula predicted spending given inputs, with reinsurance payments included 
- pred\_constraint: risk adjustment formula constraining predicted group spend = mean group spend
- pred\_constraint2: risk adjustment formula constraining predicted group spend to levels from original regression
- pred\_penaltymixed: risk adjustment formula penalizing misprediction of groups.

The output also includes indictors for membership in one of the four chronic condition groups (cancer, diab, heart, mental) that were used in the constraints and penalties.


