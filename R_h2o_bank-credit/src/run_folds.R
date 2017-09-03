# loop all folds
for (i in 1:k) {
  # Train data
  trainData <- read.csv(sprintf('data/CVfold%d-train.csv',i))
  Xtrain <- trainData[,-which(names(trainData) %in% "y")]
  Ytrain <- trainData[,"y"]
  
  # Test data
  testData <- read.csv(sprintf('data/CVfold%d-test.csv',i))  
  Xtest <- testData[,-which(names(testData) %in% "y")]  
  target <- as.logical(testData[,"y"])
  
  source('src/run_models.R')
}
