# title: "xfold_regs.R"
# author: Anna Zink
# created: 08/09/2019
# updated: 03/24/2021
# description: Function to run x-fold cross validation to constrain or penalize the 
#              risk adjustment formula (in parallel)

## Load required packages
library(dplyr)
library(CVXR)
library(foreach)
library(doParallel)

set.seed(1234)

# create function to run cross-validation on different datasets
run_xfold<-function(train,folds=10, screen=0, N=100000, nscreenvars=20,ot_methods=1){

# create 10-folds in train data 
nfolds<-folds
train$folds<-cut(seq(1,nrow(train)),breaks=nfolds,labels=FALSE)
folds<-train$folds

# create empty dataset to store data from each fold
n<-nrow(train)/nfolds
tmp_data<-data.frame(fold=integer(n), pred_ols=double(n), pred_ols_og=double(n), pred_constraint=double(n), pred_constraint2=double(n), pred_penalty=double(n), pred_rf=double(n))

# create empty final dataset
final_data<-tmp_data[0,]

# loop through each fold to run the analysis
numCores<-5
registerDoParallel(numCores)

results<-foreach(i=1:nfolds,.packages=c('CVXR'),.combine=rbind) %dopar% {

  # load functions
  source('helper_functions.R')
  
  ### PREPROCESS DATA ###
  index<-which(folds==i)
  test_i<-train[index,]
  train_i<-train[-index,]
  
  # define design matrix X and outcome y for train and test datasets
  y<-train_i$totpay_r
  yall<-train_i$totpay
  X<-train_i[,!(names(train_i) %in% c('X','totpay','totpay_r','mental','cancer','diab','heart','folds','MAGE_LAST_21_24'))]
  print(names(X))
 
  y_test<-test_i$totpay_r
  y_totpay<-test_i$totpay
  X_test<-test_i[,!(names(test_i) %in% c('X','totpay','totpay_r','mental','cancer','diab','heart','folds','MAGE_LAST_21_24'))]
  
  # screen variables if option set
  if (screen==1) {
      print('screening...')
      agevars<-names(train_i)[grep("AGE",names(train_i))]
      finalvars<-screen.glmnet(X,y,nVar=nscreenvars, keepvars=agevars)
      print("screening final vars:")
      print(finalvars)
      X<-X[,(names(X) %in% finalvars)]
      X_test<-X_test[,(names(X_test) %in% finalvars)]
  }

  # indicators for whether observation is in various subgroups
  grp1<-train_i$cancer
  grp2<-train_i$diab
  grp3<-train_i$heart
  grp4<-train_i$mental
  
  n_grp1<-sum(grp1)
  n_grp2<-sum(grp2)
  n_grp3<-sum(grp3)
  n_grp4<-sum(grp4)

  # Scale data before optimizing 
  y_scale<-scale(y)
  yall_scale<-scale(yall)
  X_scale<-scale(X)
  
  # calculate avg costs, rein costs, and % costs cov'red by rein for those in (and not in) groups & scale 
  avg1<-mean(train_i[train_i$cancer==1,'totpay'])
  avg2<-mean(train_i[train_i$diab==1,'totpay'])
  avg3<-mean(train_i[train_i$heart==1,'totpay'])  
  avg4<-mean(train_i[train_i$mental==1,'totpay'])
   
  grp1_scale<-(avg1-mean(y))/sd(y)
  grp2_scale<-(avg2-mean(y))/sd(y)
  grp3_scale<-(avg3-mean(y))/sd(y)
  grp4_scale<-(avg4-mean(y))/sd(y)

  # set to whatever original value you want to mantain
  grp1_og_scale<-(avg1*.91-mean(y))/sd(y)
  grp2_og_scale<-(avg2*1-mean(y))/sd(y)
  grp3_og_scale<-(avg3*.82-mean(y))/sd(y)
  grp4_og_scale<-(avg4*.80-mean(y))/sd(y)

  # scale test data based on the train dataset (scale used for predictions)
  X_test_scale<-sweep(sweep(X_test, 2L,attr(X_scale, 'scaled:center')), 2, attr(X_scale, 'scaled:scale'), "/")
  y_test_scale<-(y_test-mean(y))/sd(y)

  ### ESTIIMATION METHODS ###

  # OLS
 model_ols<-lm(y_scale~X_scale+0)
 beta_ols = as.matrix(coef(model_ols))
 preds_ols<-get_preds(beta_ols, X_test_scale, y_scale)

  # Get result without reinsurance 
 if (ot_methods==0) {
  model_ols_og<-lm(yall_scale~X_scale+0)
  beta_ols_og<-as.matrix(coef(model_ols_og))
  preds_ols_og<-get_preds(beta_ols_og, X_test_scale, yall_scale)
  print('ols complete')
}

 if (ot_methods==1) {
  # set up preliminaries for CVXR package 
  k<-length(beta_ols)
  beta<-Variable(k)
  loss<-sum((y_scale-X_scale %*% beta)^2)
  obj<-loss
  
  # constrained regression with 4 groups
  prob<-Problem(Minimize(obj),list((t(grp1) %*% (X_scale %*% beta))/n_grp1==grp1_scale,(t(grp2) %*% (X_scale %*% beta))/n_grp2==grp2_scale,(t(grp3) %*% (X_scale %*% beta))/n_grp3==grp3_scale,(t(grp4) %*% (X_scale %*% beta))/n_grp4==grp4_scale))
  result<-solve(prob)
  beta_constraint<-result$getValue(beta)
  preds_constraint<-get_preds(beta_constraint, X_test_scale, y_scale)
  print(paste("constrained reg 4 groups:", result$status))

  # constrained regression with 4 groups - constraint to base level 
 prob<-Problem(Minimize(obj),list((t(grp1) %*% (X_scale %*% beta))/n_grp1==grp1_og_scale,(t(grp2) %*% (X_scale %*% beta))/n_grp2==grp2_og_scale,(t(grp3) %*% (X_scale %*% beta))/n_grp3==grp3_og_scale,(t(grp4) %*% (X_scale %*% beta))/n_grp4==grp4_og_scale))
 result<-solve(prob)
 beta_constraint2<-result$getValue(beta)
 preds_constraint2<-get_preds(beta_constraint2, X_test_scale, y_scale)
 print(paste("constrained v2 reg 4 groups:", result$status))

  # net compensation penatly with 4 groups  - diff penalties 
  prob<-Problem(Minimize(loss+N/100*penalty(beta,X_scale, grp1,grp1_scale)+0*penalty(beta,X_scale, grp2,grp2_scale)+N/100*penalty(beta,X_scale, grp3,grp3_scale)+N/10*penalty(beta,X_scale, grp4,grp4_scale)))
  result<-solve(prob)
  beta_penalty<-result$getValue(beta)
  preds_penaltymixed<-get_preds(beta_penalty, X_test_scale, y_scale)
  print(paste("net compensation 4 groups mixed penalty", result$status))

# end ot methods 
} 
   
  # create data for results from this fold
  tmp_data<-test_i[,c('folds','totpay_r','totpay','cancer','diab','heart','mental')]
  tmp_data$pred_ols<-preds_ols 
if (ot_methods==0) {  tmp_data$pred_ols_og<-preds_ols_og  }
  if (ot_methods==1){
   tmp_data$pred_constraint<-preds_constraint
   tmp_data$pred_constraint2<-preds_constraint2
   tmp_data$pred_penaltymixed<-preds_penaltymixed
  }

  # return dataset
  tmp_data
# end fold
}

# end function
return(results)
}

