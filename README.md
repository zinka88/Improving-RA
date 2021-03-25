# Code for "Improving the Performance of Risk Adjustment Systems: Constrained Regressions, Reinsurance, and Variable Selection"

# Summary
This set of programs runs the risk adjustment formula using different sets of input variables
and types of constraints/penalties. It outputs predicted values for each scenario, which can be used
to summarize performance across estimation methods.

# Programs
- run\_analysis.R - runs analysis programs. Calls:
  - xfold\_regs.R - runs x-fold crossvalidation (in parallel processes) to risk adjustment using constrained an penalized methods. Calls:
    - screener.R - screens out variables before running risk adjustment prediction 
    - helper\_functions.R  

# Data
The programs uses the simulated data found in the "data" folder. This simulated data contains information on individual sex x 5-year age buckets, health conditions categories (HCCs), drug-related condition categories (RXCs), annual health spending (totpay), and annual health spending with reinsurance included (totpay\_r).
 
