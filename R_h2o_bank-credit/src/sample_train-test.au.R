## Prepare Train and Test datasets
set.seed(1234)
ix<-sample(1:nrow(d), nrow(d) * 0.8)
train<-d[ix,]
test<-d[-ix,]
rm(ix)
