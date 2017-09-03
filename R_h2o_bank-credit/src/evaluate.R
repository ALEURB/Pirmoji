##### EVALUATE MODELS #####
# summary
summary(results)
# fix names
names(results) <- c( 'model','score','target' )
results$target <- as.logical( results$target )
# save results to file for next step
# write.csv( results, file='output/results.csv' )
# results <- read.csv('output/results.csv', header=T)

# output
myModels <- levels(results[,"model"])
myModelNames <- NULL
x11();det.plot(NULL,1)
for (i in 1:length(myModels)) {
  performance <- det.plot(
    results[ results[,"model"] == myModels[i], ]
  , i+1
  )
  myModelNames[i] <- sprintf(
    '%s [ EER=%5.2f%%, AUC=%5.3f ]'
  , myModels[i]
  , performance['eer']
  , 1 - performance['pAUC']
  )
}
legend(
  x=-3
, y=-2.2
, myModelNames
, lty=rep( 1, 1, length(myModels) )
, col=2:(length(myModels)+1)
)