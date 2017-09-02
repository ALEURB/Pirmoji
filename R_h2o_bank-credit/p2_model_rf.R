#### Title: Bank Credit Model exploration ####
# Author: Aleksandras Urbonas
# Version: 29AUG2017
# time of execution
timestamp()
# cleanup
rm(list=ls())
# set work dir
setwd('C:/bank-credit/')
# load lib
# library(caret) # for folds
# library(randomForest)
# load model data
load('data/d_model.RData')

#### Sample ####
# sample proportions
source('src/sample_down.au.R')
# sample 80%
d<-d[ sample(1:nrow(d), nrow(d) * 1 ), ]
source('src/sample_train-test.au.R')
save(d, train, test, file='output/train_test.rData')
rm(d, train, test)

### Model: Random Forest ####
## Tune RF Parameters
source('src/RF_tune.R')
## Prepare Final RF Model
source('src/RF_run.R')
## Evaluate Final RF Model
source('src/RF_eval.R')

#### Evaluate models #####
source('p3_evaluate.R')
