## Pasiruošimas: globalūs kintamieji
myFoldVar <- d$y
k <- 2 # maišymai

## Duomenų maišymas
{
  myFolds<-createFolds(myFoldVar,k)
  for(i in 1:length(myFolds)) {
    tstInd<-myFolds[[i]]
    trnIdx<-as.logical(rep(1,1,nrow(d)))
    trnIdx[tstInd]<-F
    trnInd<-which(trnIdx)
    write.csv(d[trnInd,],sprintf('CVfold%d-train.csv',i),row.names=F)
    write.csv(d[tstInd,],sprintf('CVfold%d-test.csv',i),row.names=F)
  }
}