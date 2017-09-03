## RF Tuning
# load('output/train_test.rData')

## Split RF features
X <- train[,-which(names(train) %in% 'y')]
Y <- factor(train[,which(names(train) %in% 'y')])
# save(X, Y, file='output/X_Y.rData')

(weights <- prop.table(table(Y))) # class weights
(T_max <- round(sqrt(nrow(X))*sqrt(ncol(X)) / 2)) # trees to create
(T_print <- round(T_max / 10)) # print error rate for every 10th tree
(mtry0 <- floor(sqrt(ncol(X))))

system.time( {
  model_mtry <- tuneRF(
    x = X,
    y = Y,
    mtryStart=mtry0,
    ntreeTry=T_max,
    stepFactor=1.5,
    improve=0.001,
    trace=T,
    do.trace=T_print,
    plot=T,
    classwt=weights,
    cutoff=weights,
    importance=F,
    strata=Y,
    replace=F
  )
} )

mtry <- model_mtry[ which.min( model_mtry[,"OOBError"] ),"mtry" ]
cat('Optimal `mtry` for RandomForest is', mtry, '\n')
save(d, X, Y, train, test, weights, T_max, T_print, mtry, file='output/rf_hyper.rData')
rm(d, X, Y, train, test, weights, T_max, T_print, mtry, model_mtry, mtry0)
