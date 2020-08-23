# start with File > New File > Text File

data {
  int<lower=1> N: // number of observations
  int<lower=0> y[N]; // outcomes
  int<lower=1> J; // number of groups
  int<lower=1, upper=J> group_ID[N]; // what group is y[n] in?
  real<lower=0> prior_scale_group; // hyperparameter
}
parameters {
  vector[J] eta;
  real mu;
  real<lower=0> sigma_group;
}
model {
  target += poisson_log_lpmf(y | eta[group_ID]); // likelihood (likelihood7?)
}
