## Libraries
# list of used packages
wants <- c(
  'caret' # sample folds
, 'data.table' # manage data in `data table` format
, 'dummies' # data processing
, 'devtools' # allows `install_github`

, 'ggplot2' # advanced graphics
, 'gmodels' # cross tables: bivariate

, 'h2o' # modelling

, 'randomForest' # modelling

, 'ROC' # model evaluation
)

# identify installed packages
has <- wants %in% rownames( installed.packages() )
# install missing packages
if( any( !has ) ) install.packages( wants[!has] )
# load packages
lapply( wants, library, character.only=T )

install_github("davidavdav/ROC")

# cleanup
rm(has, wants)