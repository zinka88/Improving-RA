# title: "run_analysis.R"
# author: Anna Zink
# created: 08/04/2019
# updated: 
# description: Run the various risk adjustment scenarios  
# input: ./data/simulated_data.csv
# output: ./output/{all, norx, screen}_results.csv which includes the 
#         predicted values for each constrained/penalized, etc. risk adjustment
#         scenario. These predicted values can be summarized and compared.

## Load required packages
library(dplyr)
library(CVXR)
library(randomForest)

set.seed(1234)

# source functions for analysis 
source('xfold_regs.R')
source('screener.R')

# read in simulated data
data<-read.csv('./data/simulated_data.csv')
vars<-names(data)
rx_vars<-vars[(grep('RXC',vars))]
norx<-data[, !(names(data) %in% rx_vars)]

#### RUN ON ALL data #### 
results<-run_xfold(data, folds=5, ot_methods=0)
write.csv(results, './output/all_results.csv', row.names = FALSE)

#### NORX data ####
results<-run_xfold(norx,folds=5, N=100000)
write.csv(results, './output/norx_results.csv', row.names=FALSE)

#### SCREENER TO KEEP ONLY 20, 30, 40, AND 50 VARS 
results<-run_xfold(norx,folds=5, screen=1, nscreenvars=20,N=100000)
write.csv(results, './output/screen_20_results.csv', row.names=FALSE)

results<-run_xfold(norx,folds=5, screen=1, nscreenvars=30,N=100000)
write.csv(results, './output/screen_30_results.csv', row.names=FALSE)

results<-run_xfold(norx,folds=5, screen=1, nscreenvars=40,N=100000)
write.csv(results, './output/screen_40_results.csv', row.names=FALSE)

results<-run_xfold(norx,folds=5, screen=1, nscreenvars=50,N=100000)
write.csv(results, './output/screen_50_results.csv', row.names=FALSE)

