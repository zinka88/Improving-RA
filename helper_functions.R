# title: helper functions
# author: Anna Zink
# created: 08/04/2019
# updated:  03/25/2021
# description: Functions used to run analysis 

# Net compensation penalty - penalize models with rev less than cost
penalty<-function(beta, X_scale, grp, avgcost){
  avgrev<-((t(grp) %*% (X_scale %*% beta))/sum(grp))
  fair<-(avgcost - avgrev)
}

# rescale y values 
rescale<-function(y_scale,pred){
  newpred<-pred*attr(y_scale,'scaled:scale')+attr(y_scale,'scaled:center')
}


# get predictions for test dataset and rescale them
get_preds<-function(beta, X_test_scale, y_scale){
  pred_scaled<-as.matrix(X_test_scale) %*% beta
  pred<-as.data.frame(rescale(y_scale, pred_scaled))
  return(pred$V1)
}

# r-squared
rsquared<-function(y,predy){
  SSR = sum((y-predy)^2)
  SST = sum((y-mean(y))^2)
  R2 = 1-SSR/SST
  return(R2)
}

# payment system fit (psf)
psf<-function(y, r, predy){
 SSR = sum((y-(predy+r))^2)
 SST = sum((y-mean(y))^2)
 R2 = 1-SSR/SST
 return(R2)
}

# mse 
mse<-function(y,predy){
  SSR = sum((y-predy)^2)
  MSE = SSR/length(y)
  return(MSE)
}

# get mean scaled cost for each group 
grp_mean_scaled<-function(df,grpvar){
  bygroup<-ddply(df, .(grpvar), summarize, meanpay=mean(totpay))
}

# net compensation
nc<-function(y,predy) {
 return(mean(predy)-mean(y))
}

nc_ps<-function(y,r,predy){
 return(mean(predy+r)-mean(y))
}

# predicted ratio
pr<-function(y,predy) {
  return(mean(predy)/mean(y))
}

pr_ps<-function(y,r,predy){
 return(mean(predy+r)/mean(y))
}

# cpm 
cpm<-function(y,predy) {
  num=sum(abs(y-predy))
  denom=sum(abs(y-mean(y)))
  return(1-num/denom)
}

cpm_ps<-function(y,r,predy){ 
  num=sum(abs(y-(predy+r)))
  denom=sum(abs(y-mean(y)))
  return(1-num/denom)
}

# load coefficients - upload coefficients for measures
load_coef<-function(file) {
  beta_tmp<-read.csv(file)
  beta<-beta_tmp$V1
  pred_scaled<-X2_scale %*% beta
  pred<-rescale(pred_scaled)
  return(pred) 
}


