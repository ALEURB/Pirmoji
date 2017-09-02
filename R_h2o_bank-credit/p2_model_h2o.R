##### PART 2: Prepare ####
# time of execution
timestamp()
# clean up
rm(list=ls())
# set work dir
setwd('C:/bank-credit/')
# load model data
load('data/d_model.RData')

#### Prepare data for with `h2o` ####
library(h2o)
local_h2o <- h2o.init(nthreads=-1) # To launch the H2O cluster, write
# h2o.init()
# sample 10%
# source('src/sample_down.au.R')
# split data to train and test
source('src/sample_train-test.au.R')
## STOP HERE - MISSING
# source('src/sample_folds.au.R')
#data to h2o cluster
train.h2o <- as.h2o(train)
test.h2o <- as.h2o(test)
# dependent variable (Purchase)
y.dep <- which( names(d) %in% 'y' )
#independent variables (dropping ID variables)
x.indep <- c(1:(y.dep-1), (y.dep+1):dim(d)[2])

# save.image('h2o.Rdata')
# load('h2o.Rdata')

#### Modelling ####
# results of one model
result <- NULL
# results of all models
results <- NULL

### Regression with `h2o`
system.time(
  model_reg_h2o <- h2o.glm(
    y=y.dep,
    x=x.indep,
    training_frame=train.h2o,
    family="gaussian"
  )
)
# check model performance
# h2o.performance(model_reg_h2o)

model <- rep("h2o:reg", nrow(test))
# make predictions
p <- as.data.frame( h2o.predict( model_reg_h2o, test.h2o )$predict )
# predictions file
result <- cbind( model, p, target = test$y )
results <- rbind( results, result )
summary(results)


#### BINOMIAL
system.time(
  model_bi_h2o <- h2o.glm(
    y=y.dep,
    x=x.indep,
    training_frame=train.h2o,
    family="binomial"
  )
)
# check model performance
# h2o.performance(model_bi_h2o)
model <- rep("h2o:binom", nrow(test))
p <- as.data.frame( h2o.predict( model_bi_h2o, test.h2o )$predict )
result <- cbind( model, p, target = test$y )
results <- rbind( results, result )
summary(results)


## Split RF features
X <- train[,-which(names(train) %in% 'y')]
Y <- factor(train[,which(names(train) %in% 'y')])

#### h2o: Random Forest ####
weights<-c(prop.table(table(Y)))
T_max<-1000
m_try<-22 # round(sqrt(ncol(d)))
system.time(
  model_rf_h2o <- h2o.randomForest(
    y=y.dep,
    x=x.indep,
    training_frame=train.h2o,
    ntrees=T_max,
    mtries=m_try
  # , sample_rate_per_class = weights
  , stopping_metric = "AUC"
  , max_depth=ncol(d)
  , seed=1235
  , balance_classes = T
  # , fold_column
  , nfolds = 10
  , fold_assignment="Stratified"
  )
)

# check model performance
h2o.performance(model_rf_h2o)
# check variable importance
h2o.varimp(model_rf_h2o)

model <- rep("h2o:RF", nrow(test))
p <- as.data.frame( h2o.predict( model_rf_h2o, test.h2o )$predict )
result <- cbind( model, p, target = test$y )
results <- rbind( results, result )


#### h2o: GBM ####
system.time(
  model_gbm_h2o <- h2o.gbm(
    y=y.dep, 
    x=x.indep, 
    training_frame=train.h2o, 
    ntrees=1000, 
    max_depth=length(x.indep), 
    learn_rate=0.1, 
    seed=1234
  )
)
## model performance ## stop here 53% = 1798 s
h2o.performance(model_gbm_h2o)
#making prediction and writing submission file
model <- rep("h2o:gbm", nrow(test))
p <- as.data.frame( h2o.predict( model_gbm_h2o, test.h2o )$predict )
result <- cbind( model, p, target = test$y )
results <- rbind( results, result )
summary(results)



#### DEEP LEARNING ####
system.time(
  model_deep_h2o <- h2o.deeplearning(
    y=y.dep,
    x=x.indep,
    training_frame=train.h2o,
    epoch=60,
    hidden=c(100,100),
    activation="Rectifier",
    seed=1235
  )
)
# h2o.performance(model_deep_h2o)

model <- rep("h2o:deep", nrow(test))
p <- as.data.frame( h2o.predict( model_deep_h2o, test.h2o )$predict )
result <- cbind( model, p, target = test$y )
results <- rbind( results, result )
summary(results)

names(results)<-c('model','score','target')
results$target <- as.logical(results$target)

# save results to file for next step
write.csv(results, file='output/results.csv')

#### Evaluate models #####
source('p3_evaluate.R')
