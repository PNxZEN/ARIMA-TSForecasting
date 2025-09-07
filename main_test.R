library(tseries)
library(forecast)
library(urca)
library(fpp2)

library(readxl)
df <- read_excel("data/Crude_oil_2025.xls")
View(df)

attach(df)

# Stationarity Test
plot.ts(Price)
adf.test(Price)

# If pval more than 0.05, then data isn't stationary (We get 0.948)
rPrice = diff(log(Price))
adf.test(rPrice) # Passed
# Now we get (0.01)
plot.ts(rPrice)

# Some more stationarity tests
pp.test(rPrice)
# H0 = Non-Stationary
# Phillips-Perron Unit Root Test
# 
# data:  rPrice
# Dickey-Fuller Z(alpha) = -1047.2, Truncation lag parameter = 7, p-value = 0.01
# alternative hypothesis: stationary

kpss.test(rPrice)
# KPSS Test for Level Stationarity
# 
# data:  rPrice
# KPSS Level = 0.27766, Truncation lag parameter = 7, p-value = 0.1


# Best fit Arima Model
auto.arima(rPrice)
# We get:
# Series: rPrice 
# ARIMA(1,0,2) with zero mean 
# 
# Coefficients:
#   ar1      ma1      ma2
# 0.7245  -0.7125  -0.0877
# s.e.  0.0868   0.0898   0.0309
# 
# sigma^2 = 0.0005065:  log likelihood = 2877.62
# AIC=-5747.25   AICc=-5747.21   BIC=-5726.85

# Create a model
modelrPrice = arima(rPrice, order = c(1, 0, 2))
# Call:
#   arima(x = rPrice, order = c(1, 0, 2))
# 
# Coefficients:
#   ar1      ma1      ma2  intercept
# 0.7297  -0.7177  -0.0871     -2e-04
# s.e.  0.0857   0.0887   0.0310      5e-04
# 
# sigma^2 estimated as 0.0005052:  log likelihood = 2877.73,  aic = -5745.46

# Writing the Equation
## rPrice(t) = (−0.0002)+(0.7297)rPrice(t−1)+(−0.7177)rPrice(t−2)+(−0.0871)et−1


# Diagnostic Check
# There should be no corr btw the residuals, and if there's some, then there's some information left in the residuals that should be used in forecasting
# So
# 1. The residuals should not be corr, and 2. the residuals should have zero mean, and 3. They are normally distributed
et = residuals(modelrPrice)
acf(et) # Correct (Not exceeding Monte-Carlo Limits)
plot.ts(et) # Correct (If a line passes through 0, no point is left)
gghistogram(et) # Correct (A Normal Dist.)

Box.test(et, lag = 10, type = c("Box-Pierce", "Ljung-Box"), fitdf = 3) # fitdf = ar1+ma
# Box-Pierce test
# 
# data:  et
# X-squared = 9.4008, df = 7, p-value = 0.2251

# H0 = Residuals follow iid
# Here pval (more than 0.05) shows our H0 is valid

shapiro.test(et)
# Shapiro-Wilk normality test
# 
# data:  et
# W = 0.96185, p-value < 2.2e-16

qqnorm(et)
qqline(et)
# These show good fit with the diagonals, but the has outliers

# Forecasting
forecastrPrice = forecast(modelrPrice, h=10)
forecastrPrice
# Point Forecast       Lo 80      Hi 80       Lo 95      Hi 95
# 1212   0.0021500241 -0.02665475 0.03095480 -0.04190308 0.04620313
# 1213   0.0056858229 -0.02312102 0.03449267 -0.03837045 0.04974209
# 1214   0.0040908443 -0.02480428 0.03298597 -0.04010043 0.04828212
# 1215   0.0029269912 -0.02601503 0.03186901 -0.04133600 0.04718999
# 1216   0.0020777296 -0.02688923 0.03104468 -0.04222341 0.04637886
# 1217   0.0014580248 -0.02752220 0.03043825 -0.04286341 0.04577945
# 1218   0.0010058273 -0.02798146 0.02999312 -0.04332640 0.04533806
# 1219   0.0006758596 -0.02831519 0.02966691 -0.04366212 0.04501384
# 1220   0.0004350827 -0.02855797 0.02942813 -0.04390596 0.04477613
# 1221   0.0002593882 -0.02873473 0.02925350 -0.04408329 0.04460206
plot(forecastrPrice)

# Forecasting in-sample
modelrPrice_1 = arima(rPrice[1:1206], order = c(1, 0, 2))
forecastrPrice_1 = forecast(modelrPrice_1, h=6)
forecastrPrice_1
# Point Forecast       Lo 80      Hi 80       Lo 95      Hi 95
# 1207  -0.0007347102 -0.02951972 0.02805030 -0.04475758 0.04328816
# 1208   0.0010493704 -0.02773723 0.02983597 -0.04297593 0.04507467
# 1209   0.0007227990 -0.02815621 0.02960181 -0.04344384 0.04488943
# 1210   0.0004848415 -0.02844312 0.02941280 -0.04375665 0.04472633
# 1211   0.0003114529 -0.02864246 0.02926536 -0.04396973 0.04459264
# 1212   0.0001851125 -0.02878257 0.02915279 -0.04411713 0.04448736

tail(rPrice)
# [1] -0.0183874008 -0.0001913326 -0.0269579013 -0.0035447064 -0.0135056671 -0.0460345163

# Checking Accuracy
accuracy(modelrPrice)
# ME       RMSE        MAE MPE MAPE      MASE         ACF1
# Training set 7.797016e-06 0.02247649 0.01666551 NaN  Inf 0.6994602 0.0003028347

# Since the MAE (Mean Abs Error) is 0.016 (less than 0.05), thus is significant, and so
# Our model is Accurate!
