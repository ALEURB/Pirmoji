#### Prepare data for with `h2o` ####

### Regression with `h2o` ####
system.time(
  model_reg_h2o <- h2o.glm(
    y=y.dep,
    x=x.indep,
    training_frame=train.h2o,
    family="gaussian"
  )
)
# save model to file
#save(model_reg_h2o, file='models/model_reg_h2o.m')
# check model performance
# h2o.performance(model_reg_h2o)

# make predictions
model = rep( "h2o:reg", nrow(test) )
p <- as.data.frame( h2o.predict( model_reg_h2o, test.h2o )$predict )
# predictions file
result <- cbind( model, predict = p, target = test$y )
results <- rbind( results, result )


#### BINOMIAL with `h2o` ####
system.time(
  model_binom_h2o <- h2o.glm(
    y=y.dep,
    x=x.indep,
    training_frame=train.h2o,
    family="binomial"
  )
)
# save model to file
save(model_binom_h2o, file='models/model_binom_h2o.m')
# check model performance
# h2o.performance(model_binom_h2o)
# predict
model <- rep("h2o:binom", nrow(test))
p <- as.data.frame( h2o.predict( model_binom_h2o, test.h2o )$predict )
result <- cbind( model, predict = p, target = test$y )
results <- rbind( results, result )


#### h2o: Random Forest ####
## Split RF features
X <- train[,-which(names(train) %in% 'y')]
Y <- factor(train[,which(names(train) %in% 'y')])

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
# save model to file
save(model_rf_h2o, file='models/model_rf_h2o.m')
# check model performance
h2o.performance(model_rf_h2o)
# check variable importance
h2o.varimp(model_rf_h2o)
# predict
model <- rep("h2o:RF", nrow(test))
p <- as.data.frame( h2o.predict( model_rf_h2o, test.h2o )$predict )
result <- cbind( model, predict = p, target = test$y )
results <- rbind( results, result )


#### GBM with `h2o`:  ####
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
# save model to file
save(model_gbm_h2o, file='models/model_gbm_h2o.m')
# model performance
h2o.performance(model_gbm_h2o)
# making prediction and writing submission file
model <- rep("h2o:gbm", nrow(test))
p <- as.data.frame( h2o.predict( model_gbm_h2o, test.h2o )$predict )
result <- cbind( model, predict = p, target = test$y )
results <- rbind( results, result )



#### DEEP LEARNING with `h2o` ####
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
# save model to file
save(model_deep_h2o, file='models/model_deep_h2o.m')
# review model performance
# h2o.performance(model_deep_h2o)


model <- rep("h2o:deep", nrow(test))
p <- as.data.frame( h2o.predict( model_deep_h2o, test.h2o )$predict )
result <- cbind( model, predict = p, target = test$y )
results <- rbind( results, result )

summary(results)
