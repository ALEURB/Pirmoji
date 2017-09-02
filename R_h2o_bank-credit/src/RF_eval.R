# load('output/model_rf.rData')
#### Analyze final model ####
print(model_rf)
## Visualize final model
plot(model_rf, main='Final RF Model')
## Model Error Rate
print(model_rf$err.rate[model_rf$ntree,]*100)
## Predict with final model ####
p <- predict(model_rf, type="response")
# p <- predict(model_rf, newdata=test[,-which(names(test)%in%'y') ], type="response")
print(table(Y,p))
p <- predict(model_rf, type="prob")
score <- round(p[,2] - p[,1], 4)
scoretarget <- data.frame(score,Y==T)
names(scoretarget)[2] <- "target"
print(det.plot(scoretarget))
## visualize RF feature importance
barplot(
  sort(100*model_rf$importance[,"MeanDecreaseAccuracy"])
, horiz=T
, cex.names = .5
, las=1
)

model <- rep("RF", nrow(test))
# make predictions
p <- predict( model_rf, newdata=test, type='prob' )
score <- p[,2] - p[,1]
# predictions file
result <- data.frame( model, score, target = as.logical(test$y) )
results <- rbind( results, result )
# summary
summary(results)
# save results to file for next step
write.csv(results, file='output/results.csv', row.names = F)
