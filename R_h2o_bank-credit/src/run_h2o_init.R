#### Prepare data for with `h2o` ####
local_h2o <- h2o.init(nthreads=-1) # To launch the H2O cluster, write
# h2o.init()

#data to h2o cluster
train.h2o <- as.h2o(train)
test.h2o <- as.h2o(test)

# dependent variable (Purchase)
y.dep <- which( names(d) %in% 'y' )
#independent variables (dropping ID variables)
x.indep <- c(1:(y.dep-1), (y.dep+1):dim(d)[2])
