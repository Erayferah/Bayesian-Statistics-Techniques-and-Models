library("car")  # load the 'car' package
data("Anscombe")  # load the data set
?Anscombe  # read a description of the data
head(Anscombe)  # look at the first few lines of the data
pairs(Anscombe)  # scatter plots for each pair of variables

model_non_inf <- lm("education ~ income + young + urban", data=Anscombe)
summary(model_non_inf)

library("rjags")

mod_string = " model {
    for (i in 1:length(education)) {
        education[i] ~ dnorm(mu[i], prec)
        mu[i] = b0 + b[1]*income[i] + b[2]*young[i] + b[3]*urban[i]
    }
    
    b0 ~ dnorm(0.0, 1.0/1.0e6)
    for (i in 1:3) {
        b[i] ~ dnorm(0.0, 1.0/1.0e6)
    }
    
    prec ~ dgamma(1.0/2.0, 1.0*1500.0/2.0)
    	## Initial guess of variance based on overall
    	## variance of education variable. Uses low prior
    	## effective sample size. Technically, this is not
    	## a true 'prior', but it is not very informative.
    sig2 = 1.0 / prec
    sig = sqrt(sig2)
} "

data_jags = as.list(Anscombe)

params = c("b", "sig")

inits = function() {
  inits = list("b"=rnorm(3,0.0,100.0), "prec"=rgamma(1,1.0,1.0))
}

mod = jags.model(textConnection(mod_string), data=data_jags, inits=inits, n.chains=3)
update(mod, 1000) # burn-in

mod_sim = coda.samples(model=mod,
                       variable.names=params,
                       n.iter=5000)

mod_csim = do.call(rbind, mod_sim) # combine multiple chains

plot(mod_sim)
gelman.diag(mod_sim)
autocorr.diag(mod_sim)
autocorr.plot(mod_sim)

plot(lfit4)

print(dic.samples(mod, n.iter = 10000))

mod_2_string = " model {
  for (i in 1:length(education)) {
    education[i] ~ dnorm(mu[i], prec)
    mu[i] = b0 + b[1]*income[i] + b[2]*young[i]
  }
  b0 ~ dnorm(0.0, 1.0/1.0e6)
  for (i in 1:2) {
    b[i] ~ dnorm(0.0, 1.0/1.0e6)
  }
  prec ~ dgamma(1.0/2.0, 1.0*1500.0/2.0)
  ## Initial guess of variance based on overall
  ## variance of education variable. Uses low prior
  ## effective sample size. Technically, this is not
  ## a true 'prior', but it is not very informative.
  sig2 = 1.0 / prec
  sig = sqrt(sig2)
} "

mod_3_string = " model {
  for (i in 1:length(education)) {
    education[i] ~ dnorm(mu[i], prec)
    mu[i] = b0 + b[1]*income[i] + b[2]*young[i] + b[3]*income[i]*young[i]
  }
  b0 ~ dnorm(0.0, 1.0/1.0e6)
  for (i in 1:3) {
    b[i] ~ dnorm(0.0, 1.0/1.0e6)
  }
  prec ~ dgamma(1.0/2.0, 1.0*1500.0/2.0)
  ## Initial guess of variance based on overall
  ## variance of education variable. Uses low prior
  ## effective sample size. Technically, this is not
  ## a true 'prior', but it is not very informative.
  sig2 = 1.0 / prec
  sig = sqrt(sig2)
} "

data_jags = as.list(Anscombe[,-4])

params = c("b", "sig")

inits_2 = function() {
  inits = list("b"=rnorm(2,0.0,100.0), "prec"=rgamma(1,1.0,1.0))
}

inits_3 = function() {
  inits = list("b"=rnorm(3,0.0,100.0), "prec"=rgamma(1,1.0,1.0))
}

mod2 = jags.model(textConnection(mod_2_string), data=data_jags, inits=inits_2, n.chains=3)
update(mod2, 1000) # burn-in

mod2_sim = coda.samples(model=mod2,
                        variable.names=params,
                        n.iter=5000)

mod2_csim = do.call(rbind, mod2_sim) # combine multiple chains

mod3 = jags.model(textConnection(mod_3_string), data=data_jags, inits=inits_3, n.chains=3)
update(mod3, 1000) # burn-in

mod3_sim = coda.samples(model=mod3,
                        variable.names=params,
                        n.iter=5000)

mod3_csim = do.call(rbind, mod3_sim) # combine multiple chains

print(dic.samples(mod2, n.iter = 10000))
print(dic.samples(mod3, n.iter = 10000))

# Q5
print(summary(mod_sim))
print(mean(mod_csim[,1] > 0.0))