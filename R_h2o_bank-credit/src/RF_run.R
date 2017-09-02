#### Part 2 - Model RF ####
## Setup
library(ROC) # for det plot
library(randomForest) # for random forest model

## Features for modelling
# read RF model hyperparams from previous step
load(file='output/rf_hyper.rData')
# results of one model
result <- NULL
# results of all models
results <- NULL

#### Final Model ####
model_rf<-randomForest(
  x=X
, y=factor(Y)
, ntree=T_max
, mtry=mtry
, classwt=weights
, cutoff=weights
, strata=Y
, replace=F
, importance=T
, nPerm=10
, do.trace=T_print
)
# save RF model to file
save(model_rf, file='output/model_rf.rData')

