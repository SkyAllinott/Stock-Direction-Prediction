# Predicting Stock Direction
## Overview
Pulling Microsoft (could utilize any stock) price data from the quantmod package, I estimate the optimal lagged LOGIT model through time series cross validation. Finally I predict the probability that the stock will increase tomorrow.

## Results
Time series cross validation selects the 20 lag model:

![lags](https://user-images.githubusercontent.com/52394699/177025831-685154af-00a9-4670-bce1-aba6959ca08f.png)

The optimal model provides probability of 50% that the stock will increase tomorrow. 

Since errors are continously decreasing and performance gain is only ~0.010 between the worst and best model, this suggests this model has little predictive power.

Furthering this assessment, when bootstrapping to obtain a confidence interval, I obtain the 95% prediction interval [0.29, 0.65]. In other words, the model is unable to to determine if its more likely the price will increase or decrease tomorrow with any precision.

## Discussing Poor Model Power
The primary reasons for the models poor performance is:
1. **Efficient market hypothesis**: Theory that if anyone was able to accurately model stock prices, this method would be built-in to expectations and lose its predictive power.
2. **Formulation of the problem as classification**: If I focused instead on predicting stock price, I could use a full ARIMA model or other models to get better results.

## Improving the Forecast
There are two main ways to improve the model:
1. **External Variables**: This model only utilizes lagged price, when other information could be utilized such as economic conditions, and sector performance.
2. **Alternative Models**: Either predicting price with ARIMA models, or switching from LOGIT to machine learning models like randomForest or XGBoost could improve accuracy.

