#### Downsample with 0 and 1 proportions ####
set.seed(1234)

# all events
dim(d0<-d[d$y==1,])
# all non-events
dim(d1<-d[d$y==0,])

length( ix<-sample( 1:nrow(d1), nrow(d0 ) ) )
dim( d1<-d1[ix,] )

d<-rbind(d0,d1)
dim(d)
rm(ix, d0, d1)
