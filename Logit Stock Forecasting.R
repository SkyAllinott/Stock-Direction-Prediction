# Packages
library(boot)
library(quantmod)
library(lubridate)
library(glarma)
library(pglm)
library(smooth)

# Data ----
getSymbols(Symbols="MSFT", src='yahoo')
dates <- seq(from = as.Date('2010-01-01') , to = end(MSFT), by = 'day')
y <- MSFT$MSFT.Adjusted[dates]
plot(y)
plot(diff(y),
     main='Day on Day Difference in MSFT',
     ylab='Change in Price (USD)')

# Creating lagged variables and prediction sets
y <- diff(y)
y.increase <- ifelse(y$MSFT.Adjusted >=0, 1, 0)
colnames(y.increase) <- 'y.increase'
names(y) <- 'y'
y.increase$tomorrow <- lag(y.increase, -1)
y.lags <- as.data.frame(lapply(0:20, function(i) lag(y, i)))
y.full <- data.frame(y.lags, y.increase$tomorrow)
head(y.full[,c(1:6, ncol(y.full))])
tail(y.full[,c(1:6, ncol(y.full))])

# Prediction ----
mod.glm <- glm(tomorrow ~ ., family=binomial, data=y.full)
n.obs <- nrow(y.full)
predict(mod.glm, newdata=y.full[n.obs,], type='response')

# The probability of GME increasing tomorrow is 0.4569. 

# Cross Validation selection of lags
preds <- rep(NA, n.obs)
initial <- 261
tsCVdirect <- function(mod, df, forecastfunction = NULL, initial = 0, window = 0, progress = FALSE){
  n <- nrow(df)
  preds <- rep(NA, n)
  j = 1
  for(i in (initial + window) : (nrow(df))) {
    if(progress == TRUE) print(paste((i-initial), "/", (n-initial)))
    df.cv <- df[j:i, ]
    mod.cv <- update(mod, data = df.cv)
    if(is.null(forecastfunction)) {
      preds[i] <- predict(mod.cv, df.cv[nrow(df.cv), ], type='response')
    } else {
      preds[i] <- forecastfunction(mod.cv, df.cv)
    }
    if(window != 0) j = j + 1
  }
  return(preds)
}

fkt.pred <- function(mod, df){
  predict(mod, newdata = df, type='response')
}
n.lag.max <- 21 # 20 lags, plus y itself. 
CV.err <- rep(NA, n.lag.max)
for(i in 1:n.lag.max){
  df.subset <- y.full[, c(ncol(y.full), 1:(i))]
  print(colnames(df.subset))
  mod.subset <- glm(tomorrow ~ ., family='binomial', data=df.subset)
  pred <- tsCVdirect(mod.subset, df.subset, initial=261)
  CV.err[i] <- mean((df.subset$tomorrow- pred)^2, na.rm=TRUE)
}

plot(CV.err,
     main='Cross Validation Errors of MSFT LOGIT Prediction Models',
     xlab='Number of Lags',
     ylab='Mean Squared Error') +
  abline(v=which.min(CV.err), col='red')
# The best model is the fullest model, with y, and all 20 lags.


# Bootstrapping Prediction Interval
index.boot <- sample(2827, 2827, replace = TRUE)
fkt.predict <- function(data, index){
  mod.boot.temp <- glm(tomorrow ~., data=data[index,], family=binomial)
  predict <- predict(mod.boot.temp, newdata=data[n.obs,], type='response')
  return(predict)
}
pred.boot <- boot(y.full, fkt.predict, R=100)
quantile(pred.boot$t, c(0.025,0.975))
# Our 95% prediction interval is [0.262, 0.653]
