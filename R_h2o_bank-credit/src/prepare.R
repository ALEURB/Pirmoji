#### Part 1: Prepare ####
# get data
d <- read.csv2('data/bank.csv', header=T)
# data structure
str(d)

#### Features: Univariate Review ####

# age: num +
hist(d$age)

# job: fac
table(d$job)
0->d$is_inc_regular
1->d$is_inc_regular[ ! d$job %in% c('housemaid','retired','student','unemployed','unknown') ]
table(d$is_inc_regular)

# marital: fac
# education: fac
# default: y/n
# balance: num
# housing: y/n
# loan: y/n
# contact: fac
# day: num -> fac
# day as factor
d$day <- factor(d$day)
# month: fac
# merge day and month
# d$mm_dd <- factor(paste0(d$month, '/', d$day))
# summary(d$mm_dd)
# duration: num
# campaign: num -> fac
hist(d$campaign)
quantile(d$campaign, probs = seq(0,1, 0.05), type = 7)
10 -> d$campaign[d$campaign >= 10]
d$campaign <- factor(d$campaign)
summary(d$campaign)
# pdays: num -> is_pdays: fac (-1=0 and >0=1)
0 -> d$is_pdays[d$pdays == -1]
1 -> d$is_pdays[d$pdays > 0]
# d$is_pdays <- factor(d$is_pdays)
# summary(d$is_pdays)

# previous: num -> is_previous: fac (0=0 and >0=1)
0 -> d$is_previous
1 -> d$is_previous[d$previous > 0]
# d$is_previous <- factor(d$is_previous)
# summary(d$is_previous)
# poutcome: fac
# y: y/n

# summary
summary(d)

#### Data Table Operations ####
d<-data.table(d)
# x11();plot(d)

## Feature review
# categorical
pie(d[,prop.table(table(marital))])
pie(d[,prop.table(table(education))])
plot(d[,prop.table(table(job))])
plot(d[,prop.table(table(day))])
plot(d[,prop.table(table(month))])
plot(d[,prop.table(table(campaign))])

## num
## Features with NA values
which(colSums(is.na(d))>0)
# all 0

# We need to encode Gender variable into 0 and 1 (good practice).
d[, default := as.numeric(as.factor(default)) - 1]
d[, housing := as.numeric(as.factor(housing)) - 1]
d[, loan := as.numeric(as.factor(loan)) - 1]
d[, y := as.numeric(as.factor(y)) - 1]


# We’ll also need to re-code the Age bins.
hist(d$age)
(brks<-c(9,19,29,39,49,59,69,79,89,99))
d$age_fac<-cut(d$age, breaks=brks, labels=seq(brks[-1]))
levels(d$age_fac)
table(d$age_fac)
xtabs(~ age_fac + y, data=d)
plot(prop.table(table(d$age_fac, d$y),1))
xtabs(~ y + age_fac, data=d)
plot(prop.table(table(d$age_fac, d$y),2))
boxplot(as.integer(age_fac) ~ y, data=d)
cdplot(as.factor(y) ~ age_fac, data=d)
chisq.test(d$age_fac, d$y)
cor(as.integer(d$age_fac), as.integer(d$y))
# d<-d[,-1] # remove age
# cleanup
rm(brks)

# Since there are three levels in City_Category, we can do one-hot encoding.
# The “4+” level of Stay_in_Current_Years needs to be revalued.
# The data set does not contain all unique IDs. This gives us enough hint for feature engineering.
# Only 2 variables have missing values. In fact, a lot of missing values, which could be capturing a hidden trend. We’ll need to treat them differently.


#Age vs Gender
ggplot(d, aes(age_fac, fill=education)) + geom_bar()
#Age vs Age Category
ggplot(d, aes(age, fill=age_fac)) + geom_bar()
# table
plot(prop.table(table(d$age_fac,d$y)))
# sharp drop: over 60 and less than 20
0->d$is_young
1->d$is_young[d$age <= 20]
d$is_young <- factor(d$is_young)
# summary(d$is_young)
0->d$is_old
1->d$is_old[d$age >= 60]
d$is_old <- factor(d$is_old)
# summary(d$is_old)

### Bivariate analysis
## Categorical
# We can also create cross tables for analyzing categorical variables. To make cross tables, we’ll use the package gmodels which creates comprehensive cross tables.
gmodels::CrossTable(d$age_fac, d$education)
# With this, you’ll obtain a long comprehensive cross table of these two variables.
# Similarly, you can analyze other variables at your end.
# Our bivariate analysis haven’t provided us much actionable insights.
# We go to data manipulation next.

#### Feature Engineering ####
# Let’s now move one step ahead, and create more new variables a.k.a feature engineering.

# During univariate analysis, we discovered that ID variables have lesser unique values as compared to total observations in the data set. It means there are User_IDs or Product_IDs must have appeared repeatedly in this data set.

# Let’s create a new variable which captures the count of these ID variables. Higher user count suggests that a particular user has purchased products multiple times. High product count suggests that a product has been purchased many a times, which shows its popularity.
#User Count
d[, User_Count := .N, by=age]
summary(d$User_Count)
hist(d$User_Count)

#Product Count
d[, Income_Count := .N, by=d$balance]
summary(d$Income_Count)
hist(d$Income_Count)

#Mean Purchase of Product
# d[, Mean_Purchase_Product := mean(KNDL_FINANCED_AMOUNT_LTL), by=KNDL_MAKE_PLACE]
# summary(d$Mean_Purchase_Product)
#Mean Purchase of User
# d[, Mean_Purchase_User := mean(KNDL_FINANCED_AMOUNT_LTL), by=age_fac]
# summary(d$Mean_Purchase_User)



#### ONE HOT ####
d <- dummy.data.frame(d, names=c("job"), sep="_")
d <- dummy.data.frame(d, names=c("marital"), sep="_")
d <- dummy.data.frame(d, names=c("education"), sep="_")
d <- dummy.data.frame(d, names=c("age_fac"), sep="_")
d <- dummy.data.frame(d, names=c("poutcome"), sep="_")
d <- dummy.data.frame(d, names=c("campaign"), sep="_")
d <- dummy.data.frame(d, names=c("contact"), sep="_")



#### Feature Types QA ####
# Before, proceeding to modeling stage,
# let's check data types of variables once,
# and make the required changes, if necessary.

as_factors <- c(
  which( names(d) %like% 'job_' )
, which( names(d) %like% 'marital_' )
, which( names(d) %like% 'education_' )
, which( names(d) %like% 'age_fac_' )
, which( names(d) %like% 'poutcome_' )
, which( names(d) %like% 'campaign_' )
, which( names(d) %like% 'contact_' )
)
# convert to factors
d[, as_factors] <- lapply(d[, as_factors], factor)
# cleanup
rm(as_factors)

# check classes of all variables
sapply(d, class)

#converting Product Category 2 & 3
# d$Product_Category_2 <- as.integer(d$Product_Category_2)
# d$Product_Category_3 <- as.integer(d$Product_Category_3)

#convert age to numeric
# d$Age <- as.numeric(d$Age)

#convert Gender into numeric
# d[, Gender := as.numeric(as.factor(Gender)) - 1]


#### Operations with `Data Frame`
# Convert to data frame
d <- data.frame(d)
# Save to file
save(d, file='data/d_model.RData')
