setwd("~/Downloads")
rm(list = ls())
cat("\014")
# ------------------------------------------------------------------------------

# Downloading stock exchange data in the given period
library(quantmod)
Msft <- getSymbols("MSFT", from="2023-01-01", to="2025-12-01", auto.assign = FALSE)
msft <- log(Msft$MSFT.Close)

Amazon <- getSymbols("AMZN", from="2023-01-01", to="2025-12-01", auto.assign = FALSE)
amzn <- log(Amazon$AMZN.Close)

# MSFT is first for the Cholesky ordering
data <- data.frame(
  Date = index(amzn),
  MSFT = as.numeric(msft),
  AMZN = as.numeric(amzn)
)

colnames(data) <- c("Date", "MSFT", "AMZN")

# Descriptive statistics and visualization

summary(data)
str(data)
colSums(is.na(data))

library(psych)
describe(data)

h <- hist(data$MSFT, plot = FALSE)
bw <- diff(h$breaks)[1]

library(ggplot2)
ggplot(data, aes(x = MSFT)) +
  geom_histogram(
    binwidth = bw,
    boundary = min(h$breaks),   
    fill = "steelblue2",
    color = "black",
    alpha = 0.6
  ) +
  labs(
    title = "Distribution of Log Closing Prices – MSFT",
    x = "Log Price",
    y = "Frequency"
  ) +
  theme_minimal(base_family = "Times New Roman")


h_amzn <- hist(data$AMZN, plot = FALSE)
bw_amzn <- diff(h_amzn$breaks)[1]
ggplot(data, aes(x = AMZN)) +
  geom_histogram(
    binwidth = bw_amzn,
    boundary = min(h_amzn$breaks),  
    fill = "orange",
    color = "black",
    alpha = 0.6
  ) +
  labs(
    title = "Distribution of Log Closing Prices – AMZN",
    x = "Log Price",
    y = "Frequency"
  ) +
  theme_minimal(base_family = "Times New Roman")

hist(data$AMZN)
hist(data$MSFT)


# plots of closing stock prices

library(ggplot2)

# AMZN
ggplot(data, aes(x = Date)) + geom_line(aes(y = AMZN, color = "AMZN"), color = "orange", size = 1) +
  labs(title = "Closing Log Stock Prices - AMAZON",
       x = "Date",
       y = "Log Price")+
  theme_minimal(base_family = "Times New Roman")

# MSFT
ggplot(data, aes(x = Date)) + geom_line(aes(y = MSFT, color = "MSFT"), color = "steelblue2", size = 1) +
  labs(title = "Closing Log Stock Prices - MICROSOFT",
       x = "Date",
       y = "Log Price")+
  theme_minimal(base_family = "Times New Roman")

# Both together
ggplot(data, aes(x = Date)) + 
  geom_line(aes(y = AMZN, color = "AMZN"), size = 1) + 
  geom_line(aes(y = MSFT, color = "MSFT"), size = 1) +
  scale_color_manual(
    values = c("AMZN" = "orange", "MSFT" = "steelblue2"),
    name = "Stock"
  ) +
  labs(
    title = "Comparison of the Closing Log Prices",
    x = "Date",
    y = "Log Price"
  ) +
  theme_minimal(base_family = "Times New Roman")
# ------------------------------------------------------------------------------

# Stationarity Check

# None of them seem stationary, checking it numerically
# ADF test and KPSS test
library(aTSA)

# H0: the time series is not stationary
# H1: it is
adf.test(data$AMZN)
# p values > 0.01 --> fail to reject H0 --> H0: AMZN is NOT stationary

adf.test(data$MSFT)
# p values > 0.01 --> fail to reject H0 --> H0: MSFT is NOT stationary

# H0: the time series is stationary
# H1: it is not
kpss_test <- urca::ur.kpss(data$AMZN) # we reject the null hypothesis of stationarity 
kpss_test@cval
kpss_test@teststat
# Test statistics bigger than critical values - we reject H0, the series non-stationarity

# H0: the time series is stationary
# H1: it is not
kpss_test <- urca::ur.kpss(data$MSFT) # we reject the null hypothesis of stationarity 
kpss_test@cval
kpss_test@teststat
# Test statistics bigger than critical values - we reject H0, the series non-stationarity

# ------------------------------------------------------------------------------

# Engle - Granger Cointegration Test

# Not stationary, but they seem move together: Cointegration?
CointReg = lm(AMZN~MSFT, data = data)
residuals = CointReg$residuals
plot.ts(residuals)

# stationarity check on residuals

# H0: the time series is NOT stationary
# H1: it is
tseries::adf.test(residuals)
# p value = 0.3173 --> fail to reject H0 --> the residuals are NOT stationary

# H0: the time series is stationary
# H1: it is not
tseries::kpss.test(residuals)
# p values < 0.01 --> reject H0 --> H1: the residuals are NOT stationary

# All in one step:
library(urca)

# H0: residuals are not stationary, no cointegration
# H1: residuals are stationary, cointegration
eg_test = ca.po(data[, c("MSFT", "AMZN")], demean = "constant", lag = "short")
summary(eg_test)

# if teststat < critval -> H0

# Value of test-statistic is: 24.2594 
# Critical values of Pu are:
# 10pct   5pct    1pct
# critical values 27.8536 33.713 48.0021

# AMZN and MSFT are NOT Cointegrated.
# We need VAR model.

# ------------------------------------------------------------------------------

# VAR modeling

# taking the first differences of the stock prices
data$d_AMZN = c(NA, diff(data$AMZN))
data$d_MSFT = c(NA, diff(data$MSFT))

hist(data$d_AMZN)
hist(data$d_MSFT)

# stationarity check

# H0: the differenced time series are NOT stationary
# H1: they are
adf.test(data$d_AMZN[!is.na(data$d_AMZN)])
adf.test(data$d_MSFT[!is.na(data$d_MSFT)])
# in both cases: p values < 0.01 --> reject H0 --> H1
#  --> both differenced time series are stationary

ggplot(data, aes(x = Date)) +
  geom_line(aes(y = d_AMZN, color = "AMZN returns")) +
  geom_line(aes(y = d_MSFT, color = "MSFT returns")) +
  scale_color_manual(
    values = c("AMZN returns" = "orange",
               "MSFT returns" = "steelblue2"),
    name = "Series"
  ) +
  labs(
    title = "Stationarity of the Differenced Time Series",
    x = "Date",
    y = "Log return"
  ) +
  theme_minimal(base_family = "Times New Roman")

# the plot seems to confirms this


# Looking for AR or MA components
acf(data$d_MSFT[-1], main = "ACF on MSFT Log-Returns")
pacf(data$d_MSFT[-1], main = "PACF on MSFT Log-Returns")

acf(data$d_AMZN[-1], main = "ACF on AMZN Log-Returns")
pacf(data$d_AMZN[-1], main = "PACF on AMZN Log-Returns")

# the ACF and PACF plots show no significant autocorrelations:
# --> no evidence for AR or MA components

# numerical evidence:

# H0: no serial correlation up to lag 24
# H1: serial correlation exists until the specified lag
library(lmtest)
bgtest(data$d_MSFT ~ 1, order = 24)
bgtest(data$d_AMZN ~ 1, order = 24)
# both p values > 0.01 --> fail to reject H0
# --> H0: no serial correlation up to lag 24
# --> no evidence for AR or MA components
# both differenced stock price series can be characterized as 
# white noise processes, no additional AR or MA terms are required.


# Lag selection
library(vars)
# Selection and VAR model now use MSFT first to reflect your assumption
VARselect(data[2:nrow(data), c("d_MSFT", "d_AMZN")], lag.max = 24)
# $selection
# AIC(n)  HQ(n)  SC(n) FPE(n) 
# 2      1      1      2 

# --> it will either be 1 or 2: try both
var1_model = VAR(data[2:nrow(data), c("d_MSFT", "d_AMZN")], p = 1, type = "const")
summary(var1_model)
# in d_AMZN equation the first lag of d_MSFT is significant on 5% significance level

var2_model = VAR(data[2:nrow(data), c("d_MSFT", "d_AMZN")], p = 2, type = "const")
summary(var2_model)
# in d_AMZN equation the first AND second lag of d_MSFT is significant on 5% significance level


# Stability and Stationarity check of models

# VAR model is stable and stationary, if all the roots are less than 1.
roots(var1_model)
# 0.013143471 0.006028042

roots(var2_model)
# 0.2763658 0.2763658 0.2485800 0.2485800

# --> both models are stable and stationary


# White Noise test on residuals

# H0: they are white noise
# H1: they are not
serial.test(var1_model)
# p-value = 0.7662 > 0.01 --> fail to reject H0: the residuals are white noise

serial.test(var2_model)
# p-value = 0.876 --> fail to reject H0: the residuals are white noise

# --> This is good because:
#     IN VAR MODEL WE ASSUME THAT THE RESIDUALS ARE WHITE NOISE.

# I will choose the VAR(1) as final model, since it was recommended by the
# stricter ICs, the ones that penalize the extra explanatory variables more.

# ------------------------------------------------------------------------------

# Granger Causality tests

# H0: d_MSFT does NOT Granger Cause d_AMZN
# H1 it does
causality(var1_model, cause = "d_MSFT")
# p-value = 0.03414 --> d_MSFT Granger Causes d_AMZN oh 5% significance level

# H0: AMZN does NOT Granger Cause d_MSFT
# H1: it does
causality(var1_model, cause = "d_AMZN")
# p-value = 0.9975 --> d_AMZN does NOT Grange Cause d_MSFT

# ------------------------------------------------------------------------------

# Impulse response functions:
plot(irf(var1_model, 
         impulse = "d_MSFT", response = "d_AMZN", 
         n.ahead = 15, ortho = TRUE))

plot(irf(var1_model, 
         impulse = "d_AMZN", response = "d_MSFT", 
         n.ahead = 15, ortho = TRUE))

# Forecast Error Variance Decomposition
fevd(var1_model)

# ------------------------------------------------------------------------------
# IRF option
irf_obj <- irf(var1_model,
               impulse = "d_MSFT",
               response = "d_AMZN",
               n.ahead = 15,
               ortho = TRUE,
               boot = TRUE)

irf_df <- data.frame(
  Horizon = 0:15,
  IRF = irf_obj$irf$d_MSFT[, "d_AMZN"],
  Lower = irf_obj$Lower$d_MSFT[, "d_AMZN"],
  Upper = irf_obj$Upper$d_MSFT[, "d_AMZN"]
)


ggplot(irf_df, aes(x = Horizon, y = IRF)) +
  geom_line(color = "red", linewidth = 1) +
  geom_ribbon(aes(ymin = Lower, ymax = Upper),
              fill = "red", alpha = 0.2) +
  theme_minimal(base_family = "Times New Roman") +
  labs(
    title = "Orthogonal Impulse Response: MSFT → AMZN",
    x = "Horizon (95% Bootstrap CI, 100 runs)",
    y = "Response"
  )


#2
irf_obj <- irf(var1_model,
               impulse = "d_AMZN",
               response = "d_MSFT",
               n.ahead = 15,
               ortho = TRUE,
               boot = TRUE)

irf_df <- data.frame(
  Horizon = 0:15,
  IRF   = irf_obj$irf$d_AMZN[, "d_MSFT"],
  Lower = irf_obj$Lower$d_AMZN[, "d_MSFT"],
  Upper = irf_obj$Upper$d_AMZN[, "d_MSFT"]
)


ggplot(irf_df, aes(x = Horizon, y = IRF)) +
  geom_line(color = "red", linewidth = 1) +
  geom_ribbon(aes(ymin = Lower, ymax = Upper),
              fill = "red", alpha = 0.2) +
  theme_minimal(base_family = "Times New Roman") +
  labs(
    title = "Orthogonal Impulse Response: AMZN → MSFT",
    x = "Horizon (95% Bootstrap CI, 100 runs)",
    y = "Response"
  )

