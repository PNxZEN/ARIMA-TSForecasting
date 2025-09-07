library(tseries)
library(forecast)
library(urca)
library(fpp2)

library(readxl)
df <- read_excel("data/BHARTIARTL.xlsx")
View(df)

attach(df)
# We'll take the Volume weighted average price for our ARIMA Analysis

# Stationarity Test
plot.ts(VWAP)
adf.test(VWAP)

# If pval more than 0.05, then data isn't stationary (We get 0.948)
rVWAP = diff(log(VWAP))
adf.test(rVWAP) # Passed
# Augmented Dickey-Fuller Test
# 
# data:  rVWAP
# Dickey-Fuller = -16.432, Lag order = 16, p-value = 0.01
# alternative hypothesis: stationary
# 
# Warning message:
#   In adf.test(rVWAP) : p-value smaller than printed p-value
# Now we get (0.01)
plot.ts(rVWAP)

# Some more stationarity tests
pp.test(rVWAP)
# Phillips-Perron Unit Root Test
# 
# data:  rVWAP
# Dickey-Fuller Z(alpha) = -3986.2, Truncation lag parameter = 10, p-value = 0.01
# alternative hypothesis: stationary
# 
# Warning message:
#   In pp.test(rVWAP) : p-value smaller than printed p-value

kpss.test(rVWAP)
# KPSS Test for Level Stationarity
# 
# data:  rVWAP
# KPSS Level = 0.37772, Truncation lag parameter = 10, p-value = 0.08676


# Best fit Arima Model
auto.arima(rVWAP)
# Series: rVWAP 
# ARIMA(1,0,2) with non-zero mean 
# 
# Coefficients:
#   ar1      ma1      ma2   mean
# 0.2702  -0.1646  -0.0919  5e-04
# s.e.  0.2664   0.2657   0.0295  3e-04
# 
# sigma^2 = 0.0005359:  log likelihood = 11203.49
# AIC=-22396.98   AICc=-22396.97   BIC=-22364.63

# Create a model
modelrVWAP = arima(rVWAP, order = c(1, 0, 2))
modelrVWAP
# Call:
#   arima(x = rVWAP, order = c(1, 0, 2))
# 
# Coefficients:
#   ar1      ma1      ma2  intercept
# 0.2702  -0.1646  -0.0919      5e-04
# s.e.  0.2664   0.2657   0.0295      3e-04
# 
# sigma^2 estimated as 0.0005354:  log likelihood = 11203.49,  aic = -22396.98

# Writing the Equation
## rVWAP(t) = (0.0005)+(0.2702)rVWAP(t−1)+(−0.1646)rVWAP(t−2)+(−0.0919)et−1


# Diagnostic Check
# There should be no corr btw the residuals, and if there's some, then there's some information left in the residuals that should be used in forecasting
# So,
# 1. The residuals should not be corr, and 2. the residuals should have zero mean, and 3. They are normally distributed
et = residuals(modelrVWAP)
acf(et) # Correct (Not exceeding Monte-Carlo Limits)
plot.ts(et) # Correct (If a line passes through 0, no point is left)
gghistogram(et) # Correct (A Normal Dist.)

Box.test(et, lag = 10, type = c("Box-Pierce", "Ljung-Box"), fitdf = 3) # fitdf = ar1+ma
# Box-Pierce test
# 
# data:  et
# X-squared = 6.5459, df = 7, p-value = 0.4776

# H0 = Residuals follow iid
# Here pval (more than 0.05) shows our H0 is valid

shapiro.test(et)
# Shapiro-Wilk normality test
# 
# data:  et
# W = 0.82675, p-value < 2.2e-16

qqnorm(et)
qqline(et)
# These show good fit with the diagonals, but the has outliers

# Forecasting
forecastrVWAP = forecast(modelrVWAP, h=10)
forecastrVWAP
# Point Forecast       Lo 80      Hi 80       Lo 95      Hi 95
# 4774   9.708528e-06 -0.02964503 0.02966444 -0.04534330 0.04536271
# 4775   6.445820e-04 -0.02917509 0.03046425 -0.04496067 0.04624983
# 4776   5.604566e-04 -0.02931844 0.03043935 -0.04513537 0.04625628
# 4777   5.377226e-04 -0.02934549 0.03042093 -0.04516471 0.04624015
# 4778   5.315790e-04 -0.02935195 0.03041511 -0.04517133 0.04623449
# 4779   5.299187e-04 -0.02935363 0.03041347 -0.04517303 0.04623287
# 4780   5.294701e-04 -0.02935408 0.03041302 -0.04517348 0.04623242
# 4781   5.293488e-04 -0.02935420 0.03041290 -0.04517360 0.04623230
# 4782   5.293160e-04 -0.02935424 0.03041287 -0.04517363 0.04623227
# 4783   5.293072e-04 -0.02935425 0.03041286 -0.04517364 0.04623226
plot(forecastrVWAP)

# Forecasting in-sample
modelrVWAP_1 = arima(rVWAP[1:4768], order = c(1, 0, 2))
forecastrVWAP_1 = forecast(modelrVWAP_1, h=6)
forecastrVWAP_1
# Point Forecast       Lo 80      Hi 80       Lo 95      Hi 95
# 4769   4.085997e-05 -0.02962711 0.02970883 -0.04533238 0.04541410
# 4770   1.096348e-03 -0.02873617 0.03092886 -0.04452855 0.04672124
# 4771   6.773617e-04 -0.02921445 0.03056917 -0.04503822 0.04639294
# 4772   5.647740e-04 -0.02933131 0.03046086 -0.04515735 0.04628690
# 4773   5.345200e-04 -0.02936188 0.03043092 -0.04518807 0.04625711
# 4774   5.263904e-04 -0.02937003 0.03042281 -0.04519624 0.04624902

tail(rVWAP)
# [1] -8.068531e-03  5.133226e-04  1.570886e-02  1.553959e-02 -1.842248e-05 -3.450984e-03

# Checking Accuracy
accuracy(modelrVWAP)
# ME       RMSE       MAE MPE MAPE      MASE          ACF1
# Training set -1.274929e-05 0.02313971 0.0151898 NaN  Inf 0.7360721 -0.0003315241

# Since the MAE (Mean Abs Error) is 0.015 (less than 0.05), thus is significant, and so
# Our model is Accurate!
