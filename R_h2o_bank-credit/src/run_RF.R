#### Part 2 - Model RF ####
## Setup

## Features for modelling
# read RF model hyperparams from previous step
load(file='output/rf_hyper.rData')

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
save(model_rf, file='models/model_rf.m')

model <- rep("RF", nrow(test))
# make predictions
p <- predict( model_rf, newdata=test, type='prob' )
p <- p[,2] - p[,1]
# predictions file
result <- data.frame( model, predict = p, target = test$y )
results <- rbind( results, result )

rm(model_rf)