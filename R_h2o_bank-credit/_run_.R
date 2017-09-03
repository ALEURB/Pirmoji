#### Bank Credit in `R` with `h2o` and `Random Forest`
# Author: Aleksandras Urbonas
# Version: 03SEP17 T1256
# R version: 3.2.5

#### Setup ####

# time of execution
timestamp()

# clean up
rm(list=ls())

# set work dir
setwd('C:/git_au/R_h2o_bank-credit/')

# load libs
source('src/library_bank-credit.R')


#### Data ####

# prepare data
source('src/prepare.R')

# sample even
source('src/sample_even.R')

# sample X%
d <- d[ sample(1:nrow(d), nrow(d) * 0.05 ), ]

# sample train and test
source('src/sample_train-test.R')


#### Models ####

# results of one model
result <- NULL
# results of all models
results <- NULL

# sample folds
source('src/sample_folds.R')

# run
source('src/run_folds.R')


#### Results #####

# evaluate model results
source('src/evaluate.R')
