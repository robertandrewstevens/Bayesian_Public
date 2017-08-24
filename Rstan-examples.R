# https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started#how-to-install-rstan

# Verify that your toolchain works by executing in R

fx <- inline::cxxfunction( signature(x = "integer", y = "numeric" ) , '
                           return ScalarReal( INTEGER(x)[0] * REAL(y)[0] ) ;
                           ' )
fx( 2L, 5 ) # should be 10

# How to Use RStan

# Load rstan

# The package name is rstan, so we need to use library(rstan) to load the package.

library(rstan) # observe startup messages

# As the startup message says, if you are using rstan locally on a multicore machine 
# and have plenty of RAM to estimate your model in parallel, at this point execute

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# These options respectively allow you to automatically save a bare version of a 
# compiled Stan program to the hard disk so that it does not need to be recompiled 
# and to execute multiple Markov chains in parallel.

# Example 1: Eight Schools

# This is an example in Section 5.5 of Gelman et al (2003), which studied coaching 
# effects from eight schools. For simplicity, we call this example "eight schools."

# First, we specify this model in a file called 8schools.stan as follows (it can be 
# found here):

# In this model, we let theta be transformed parameters of mu and eta instead of 
# directly declaring theta as parameters. By parameterizing this way, the sampler 
# will run more efficiently. Assuming we have 8schools.stan file in our working 
# directory, we can prepare the data and fit the model as the following R code shows.

schools_dat <- list(J = 8, 
                    y = c(28,  8, -3,  7, -1,  1, 18, 12),
                    sigma = c(15, 10, 16, 11,  9, 11, 10, 18))
setwd("~/GitHub/Bayesian")
fit <- stan(file = '8schools.stan', data = schools_dat, 
            iter = 1000, chains = 4)

# We can also specify a Stan model using a character string by using argument 
# model_code of function stan instead. However, this is not recommended.

# The object fit, returned from function stan is an S4 object of class stanfit. 
# Methods such as print, plot, and pairs are associated with the fitted result 
# so we can use the following code to check out the results in fit. print provides 
# a summary for the parameter of the model as well as the log-posterior with name 
# lp__ (see the following example output). For more methods and details of class 
# stanfit, see the help of class stanfit.

# In particular, we can use extract function on stanfit objects to obtain the samples. 
# extract extracts samples from the stanfit object as a list of arrays for parameters 
# of interest, or just an array. In addition, S3 functions as.array and as.matrix are 
# defined for stanfit object (using help("as.array.stanfit") to check out the help 
# document in R).

print(fit)
plot(fit)
pairs(fit, pars = c("mu", "tau", "lp__"))

la <- extract(fit, permuted = TRUE) # return a list of arrays 
mu <- la$mu 

### return an array of three dimensions: iterations, chains, parameters 
a <- extract(fit, permuted = FALSE) 

### use S3 functions as.array (or as.matrix) on stanfit objects
a2 <- as.array(fit)
m <- as.matrix(fit)
print(fit, digits = 1)

# In addition, as in BUGS (or JAGS), CmdStan (the command line interface to Stan) 
# needs all the data to be in an R dump file. In the case we have this file, rstan 
# provides function read_rdump to read all the data into an R list. For example, 
# if we have a file named "8schools.rdump" that contains the following text in our 
# working directory.

J <- 8
y <- c(28,  8, -3,  7, -1,  1, 18, 12)
sigma_y <- c(15, 10, 16, 11,  9, 11, 10, 18)

# Then we can read the data from "8schools.rdump" as follows.

schools_dat <- read_rdump('8schools.rdump')

# The R dump file actually can be sourced using function source in R into the 
# global environment. In this case, we can omit the data argument and stan will 
# search the calling environment for objects that have the same names as in the 
# data block of 8schools.stan. That is,

source('8schools.rdump') 
fit <- stan(file = '8schools.stan', iter = 1000, chains = 4)

# Example 2: Rats

# The Rats example is also a popular example. For example, we can find the OpenBUGS 
# version from here, which originally is from Gelfand et al (1990). The data are 
# about the growth of 30 rats weekly for five weeks. In the following table, we 
# list the data, in which we use x to denote the dates the data were collected. 
# We can try this example using the linked data rats.txt and model code rats.stan.

#y <- read.table('https://raw.github.com/wiki/stan-dev/rstan/rats.txt', header = TRUE)
y <- read.table('rats.txt', header = TRUE)
x <- c(8, 15, 22, 29, 36)
xbar <- mean(x)
N <- nrow(y)
T <- ncol(y)
#rats_fit <- stan(file = 'https://raw.githubusercontent.com/stan-dev/example-models/master/bugs_examples/vol1/rats/rats.stan')
rats_fit <- stan(file = 'rats.stan')

# Example 3: Anything

# You can run many of the BUGS examples and some others that we have created in Stan 
# by executing

model <- stan_demo()

# and choosing an example model from the list that pops up. The first time you call 
# stan_demo(), it will ask you if you want to download these examples. You should 
# choose option 1 to put them in the directory where rstan was installed so that 
# they can be used in the future without redownloading them. The model object above 
# is an instance of class stanfit, so you can call print, plot, pairs, extract, etc. 
# on it afterward.

