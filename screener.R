# Name: screener.R
# Author: Anna Zink
# Date: 8/21/2019
# Description: Screener function with glmnet 
# Resource: https://github.com/sl-bergquist/SLscreeners/blob/master/R/specify_variables.R


library(glmnet)

# see glmnet for parameters description
screen.glmnet<-function(X,Y,family='gaussian', alpha=1, minscreen=2, nVar=20, nlambda=100, keepvars=NULL) {
  if(!is.matrix(X)){
   Xmat<-model.matrix(~0 + ., X)
  }  
  fitCV <- glmnet(Xmat, Y, lambda = NULL, family = family, alpha =alpha,nlambda = nlambda)
  # find lambdas with enough nonzero coefficients at each lambda & get lambda value with 
  # smallest cvm but enough variables 
  nCoefs<-colSums(fitCV$beta!=0)
  print(nCoefs)
  lambda_index<-nCoefs<=nVar 
  idx<-max(which(lambda_index))
  print(idx)
  getl<-fitCV$lambda[idx] 
  getcoeff<-coef.glmnet(fitCV, s =getl)
  # keep non-zero coefficents & all prespecified variables 
  whichVars<-(as.numeric(getcoeff)!=0)
  vars<-rownames(getcoeff)[whichVars][-1]
  finalvars<-c(vars, keepvars)
  return(unique(finalvars))
}

