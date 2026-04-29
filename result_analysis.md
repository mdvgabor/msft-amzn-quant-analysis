# VAR and Cointegration Analysis: Microsoft and Amazon Stock Prices

## Table of Contents

- [Introduction](#introduction)
- [Dataset Description](#dataset-description)
- [Descriptive Statistics of the Dataset](#descriptive-statistics-of-the-dataset)
- [Company Overview](#company-overview)
- [Methodology](#methodology)
  - [Stationarity](#stationarity)
  - [Box-Jenkins Modeling](#box-jenkins-modeling)
  - [Cointegration](#cointegration)
  - [VAR Model](#var-model)
- [Results](#results)
  - [Stationarity](#stationarity-1)
  - [Box-Jenkins Modeling](#box-jenkins-modeling-1)
  - [Cointegration](#cointegration-1)
  - [VAR Model](#var-model-1)
- [Conclusion](#conclusion)
- [References](#references)

## Introduction

In recent years, technology stocks have been at the center of global financial markets, driven by rapid innovation, digital transformation, and the accelerating development of artificial intelligence. Companies like Microsoft and Amazon have key roles in these developments. They are not only large technology firms but also platform providers whose cloud and AI services affect many industries. The rapid growth of AI, increased spending on cloud infrastructure, and changing expectations about future growth have increased volatility and caused large technology stocks to move more closely together.

The main research questions of this study are whether there is co-movement between the stock prices of Microsoft and Amazon and whether the movements can be forecasted. More specifically, the analysis examines whether the stock price movements of Microsoft and Amazon are related, whether changes in one stock can help predict changes in the other, and whether the two stocks move together in the long run or mainly interact in the short run due to shocks.

To address these questions, several time series methods are applied. First, stationarity tests are used to examine the properties of the stock price series. Box-Jenkins modeling is then applied to analyze the individual time series dynamics and identify appropriate autoregressive and moving average structures. Next, cointegration analysis is used to test whether a long-term relationship exists between Microsoft and Amazon. If no such relationship is found, a Vector Autoregressive (VAR) model is estimated using differenced data to capture short-term interactions between the two stock returns. Within the VAR framework, Granger causality tests, impulse response functions, and forecast error variance decomposition are used to study how shocks are transmitted between the two stocks over time.

## Dataset Description

The two datasets that were used, the one of Microsoft Corporation (MFST) and the one of Amazon.com Inc. (AMZN) were both obtained from Yahoo Finance (Yahoo Finance, 2025a) (Yahoo Finance, 2025b). They were downloaded using the `quantmod()` package, since it directly provides access to the data on Yahoo Finance. Both datasets are daily closing stock price data from 1 January 2023 until 1 December 2025, and since both of them are financial datasets, right after downloading them, their logarithms were taken, this made the interpretation easier and also stabilized the variances.

Then the datasets were combined in a common dataframe based on their date values, therefore it has 3 variables of 730 observations: a date variable and two numeric variables, MSFT and AMZN in this order. The order is important since impulse response functions and forecast error variance decomposition in the VAR model are identified using Cholesky decomposition, which requires an ordering assumption among the variables. In this study, the ordering `MSFT -> AMZN` was used, placing Microsoft before Amazon. This choice was made based on Microsoft's dominant role in enterprise software, cloud infrastructure, and AI services, which makes it possible that shocks to Microsoft can affect Amazon at the same time. In contrast, Amazon-specific shocks related to e-commerce or consumer demand are less likely to have an immediate impact on Microsoft within the same period. This ordering does not imply true causality but serves as a structural identification assumption for interpreting the impulse response functions.

## Descriptive Statistics of the Dataset

To get a broad perspective of the dataset, different functions were run, which, for example confirmed what I would expect based on the nature of the dataset, that there are no missing values. While the average logarithmized closing price of Microsoft is 5.97 and its median is 6.02, Amazon's logarithmized values are lower, with an average of 5.12 and a median of 5.20, and based on the fact that in both cases the mean is a little bit lower than the median, it can be assumed that there is a slight asymmetry in the distributions and also that the values of Microsoft are generally higher than Amazon's.

![Comparison of the Amazon and Microsoft log closing prices](/Users/medvegygabor/Desktop/msft_amzn/figures/page-05-img-01-Im1.png)

*Figure 1. Comparison between the Amazon and the Microsoft log closing prices.*

However, in the case of standard deviation and total range, Amazon has larger values, for standard deviation, its figure is 0.27, which is 0.07 higher than Microsoft's (when talking about logarithmized values).

For the logarithmized Microsoft closing stock prices, based on the histogram, there is a strong concentration around 6, which is almost equivalent to the mean and the median, however based on these two values and a skewness of -0.67, it can be stated that it is a mildly left-skewed distribution. In the case of Amazon's logarithmized closing prices, as it has a higher standard deviation, there is a larger spread between the values, and as can be observed on the histogram and in the results of the `describe()` function with a -0.66 skewness value, this distribution is also mildly left-skewed. As for kurtosis, both distributions have negative values, which indicates that they are flatter than a normal distribution would be.

![Distribution of log closing prices for Microsoft](/Users/medvegygabor/Desktop/msft_amzn/figures/page-06-img-01-Im2.png)

![Distribution of log closing prices for Amazon](/Users/medvegygabor/Desktop/msft_amzn/figures/page-06-img-02-Im3.png)

*Figure 2. Distributions of Amazon and Microsoft log closing prices.*

## Company Overview

Microsoft is a global technology company that provides software, cloud computing, productivity tools, and AI services. In the AI industry, Microsoft is a leader in enterprise solutions, mainly through its Azure cloud platform. Azure provides the computing power needed to run large-scale AI applications (Microsoft, 2025). Microsoft has a strong partnership with OpenAI. OpenAI's APIs run exclusively on Azure, and Azure provides the cloud capacity for OpenAI's products (Microsoft, 2023). This partnership allows Microsoft to integrate AI into its products, like Microsoft 365 Copilot, which adds AI features to Word, Excel, Teams, and Outlook, and GitHub Copilot, which helps developers write code (OpenAI, 2023). Microsoft's main advantages are its enterprise customers, integrated AI ecosystem, and strong cloud platform.

Amazon is a global e-commerce and cloud company. Amazon Web Services (AWS) is the largest cloud provider in the world and the backbone for many AI applications. AWS provides tools for building, training, and running AI models. Amazon's advantages include its huge cloud scalability, flexibility for AI workloads, and strong AI partnerships (Amazon Web Services, 2024). AWS also has a major partnership with OpenAI, allowing OpenAI to run its AI models on AWS (OpenAI, 2025).

Microsoft and Amazon are each other's main challenge in the AI market. Both companies have strategic partnerships with OpenAI, which allow them to offer access to advanced AI models on their cloud platforms. It would also be valuable to investigate OpenAI's role in these relationships, but since OpenAI is a private company, daily stock information is not available. This makes it especially important to study the interdependencies between Microsoft and Amazon to understand how they compete and collaborate in the AI industry.

## Methodology

### Stationarity

Before analyzing the time series, it is essential to examine whether the stock price series are stationary. A stationary series has constant statistical properties, such as mean, variance, and autocorrelation over time (Hamilton, 1994). Stationarity is a critical assumption for most time series models, including Box-Jenkins modelling and vector autoregressive models, as non-stationary data can produce misleading results.

In this analysis, the Augmented Dickey-Fuller (Fuller, 1996), ADF test and the Kwiatkowski-Phillips-Schmidt-Shin (Kwiatkowski et al., 1992), KPSS test are applied to the daily stock price series of Microsoft and Amazon. The ADF test has a null hypothesis that the series contains a unit root and is non-stationary, whereas the alternative hypothesis is that the series is stationary. In contrast, the KPSS test assumes stationarity under the null hypothesis and non-stationarity under the alternative. These complementary tests determine whether differencing is required to achieve stationarity.

### Box-Jenkins Modeling

The Box-Jenkins methodology (Box et al., 2015) is applied to model the individual series of Microsoft and Amazon. This approach involves three main steps: identification, estimation, and diagnostic checking, using autoregressive (AR) and moving average (MA) models to capture the autocorrelation structure in the data. During the identification step, Autocorrelation Function (ACF) and Partial Autocorrelation Function (PACF) values are examined to determine the appropriate orders for the AR and MA components of the model. Then Autoregressive Integrated Moving Average (ARIMA) models are estimated by maximum likelihood estimation. Finally, on the final model, residual analysis is performed to ensure that the model adequately captures the serial correlation in the series and that the residuals behave like white noise.

### Cointegration

Sometimes two time series that are non-stationary but integrated of the same order (I(1) most of the time) might exhibit a stable long-run equilibrium relationship, meaning that they might share a common stochastic trend, adjusting to each other when necessary. This is known as cointegration, and its main idea is that even if individual series drift over time, there might be a specific linear combination of them that is stationary. (Hamilton, 1994)

When series are modeled on levels, it often leads to spurious regression (Granger & Newbold, 1974), and when only in differences, it might obscure long-run relationships. Technically, to test for cointegration between Microsoft and Amazon stock prices, the Engle-Granger two-step procedure is applied. (Engle & Granger, 1987) First, a long-run relationship is estimated using the level values of the two series. Then, a unit root test, the Augmented Dickey-Fuller test without a constant or a trend, is done on the residuals of this regression (Fuller, 1996). If residuals are stationary, the presence of cointegration is likely, while non-stationarity implies the absence of such a relationship (Engle & Granger, 1987).

If cointegration is detected, an error correction model (ECM) is estimated to examine the adjustment toward long-run equilibrium. The ECM is specified for each variable in differences, including lagged differences of both series, along with a lag of the residuals of the cointegration model. The significance of the lags is examined, the models are refined, and the significance and sign of the error correction term is inspected to assess whether deviations from the long-run equilibrium are corrected over time. (Hamilton, 1994; Lütkepohl, 2005) If no cointegration is found, the analysis proceeds with a Vector Autoregressive (VAR) model in differences.

### VAR Model

If the time series are stationary in differences or no cointegration is detected, a Vector Autoregressive (VAR) model is applied to examine the short-term interactions between Microsoft and Amazon stock returns. The VAR model allows each variable to be expressed as a linear function of its own past values and the past values of the other variable, making it well-suited for analyzing interdependencies in multivariate time series (Lütkepohl, 2005).

Within the VAR framework, Granger causality tests are conducted to determine whether the past values of one stock improve the forecast of the other stock beyond what its own past values can explain (Clarke & Granato, 2005). These tests do not indicate true causality but rather statistical predictive ability. Finally, impulse response functions (IRF) and forecast error variance decomposition (FEVD) are applied. The IRF allows me to assess how a one standard deviation shock to a given stock affects the other stock over time (Lütkepohl, 2005). The FEVD evaluates the proportion of the forecast error variance attributable to the stock's own shocks versus shocks from the other stock at different time horizons (Aptech Systems, 2021). This provides insight into whether a given shock affects forecasts only in the short term or also over longer horizons.

## Results

### Stationarity

The ADF tests applied to the original series of AMZN and MSFT indicate non-stationarity, as the p-values in both cases are above the 1% significance level. Accordingly, the null hypothesis of a unit root cannot be rejected for either stock price series. The KPSS test results share the same conclusion, as the null hypothesis of stationarity is rejected for both AMZN and MSFT at the 1% level.

After taking first differences, visually it seems taking the first difference was enough to reach stationarity, but I also conducted the proper statistical tests to confirm this finding: the ADF tests strongly reject the null hypothesis of non-stationarity for both AMZN and MSFT, with p-values below 1%. This confirms formally that the differenced series are stationary. Taken together, these results imply that both stock price series are integrated of order one, I(1).

![Differenced stationary time series of Amazon and Microsoft](/Users/medvegygabor/Desktop/msft_amzn/figures/page-10-img-01-Im6.png)

*Figure 3. The differentiated stationary time series of Amazon and Microsoft.*

### Box-Jenkins Modeling

The Box-Jenkins methodology was then applied to the first-differenced stock price series of Amazon and Microsoft, which were previously found to be stationary. For Amazon, inspection of the ACF and PACF reveals no statistically significant spikes at any lag. This suggests the absence of autoregressive (AR) or moving average (MA) processes in the differenced series.

Consequently, a Breusch-Godfrey test for autocorrelation was conducted up to lag 24. The test fails to reject the null hypothesis of no autocorrelation (`p-value = 0.869`), indicating that the differenced Amazon series behaves as white noise.

![ACF on Amazon log returns](/Users/medvegygabor/Desktop/msft_amzn/figures/page-10-img-02-Im7.png)

![PACF on Amazon log returns](/Users/medvegygabor/Desktop/msft_amzn/figures/page-10-img-03-Im8.png)

*Figure 4. The ACF and PACF on Amazon log returns.*

Similar results are obtained for Microsoft, the ACF and PACF plots show no significant autocorrelations, providing no evidence for AR or MA components. The Breusch-Godfrey test up to lag 24 also fails to reject the null hypothesis of no serial correlation (`p-value = 0.4647`), confirming the absence of autocorrelation in the differenced Microsoft series. Overall, the Box-Jenkins analysis indicates that both differentiated stock price series can be characterized as white noise processes, no additional AR or MA terms are required.

![ACF on Microsoft log returns](/Users/medvegygabor/Desktop/msft_amzn/figures/page-11-img-01-Im9.png)

![PACF on Microsoft log returns](/Users/medvegygabor/Desktop/msft_amzn/figures/page-11-img-02-Im10.png)

*Figure 5. The ACF and PACF on Microsoft log returns.*

### Cointegration

As the series of both Microsoft and Amazon stock prices were found to be of I(1), meaning integrated of order one, an analysis of cointegration was deemed necessary to find whether a long-run equilibrium relationship exists between the two series.

I applied the Engle-Granger two-step cointegration test. First, Amazon's stock price was regressed on Microsoft's stock price, with the residuals of this simple regression being saved. Then, the stationarity of these residuals was tested, both with ADF and KPSS tests. The ADF test failed to reject the null hypothesis of non-stationarity (returning a `p-value` of `31.73%`), while the KPSS test rejected the null hypothesis of stationarity even at 1% level. Both tests were applied in their default format, without fitting a trend, as I am talking about residuals. Therefore, both tests consistently indicated that the residuals are non-stationary, providing no evidence of cointegration between the two given series.

To confirm the results, I also applied the Philips-Ouilaris test. The null hypothesis of this test claims that residuals are not stationary, implying that there is no cointegration between the two series. In the case of this test, the value of the test-statistic turned out to be `24.2594`, which is smaller than all critical values (the critical value at 10% being `27.8536` and at 5% `33.713`). Consequently, the null hypothesis cannot be rejected, and thus this test confirms the absence of cointegration.

Overall, the cointegration analysis provided no evidence of any cointegration being present, meaning there is no long-run equilibrium between the stock prices of Microsoft and Amazon. Even though, as it can be visually examined, the two series might exhibit some short-run co-movements, this does not seem to be the case in the long term. Therefore, modeling the relationship between Amazon and Microsoft stock prices using a Vector Error Correction Model (VECM) is not appropriate; instead, their dynamic interaction is analyzed using a Vector Autoregressive (VAR) model.

### VAR Model

In the prior chapter, cointegration analysis indicated that no long-run equilibrium relationship exists between the stock prices of Microsoft and Amazon. As a result, the interaction between the two series is modeled using a VAR framework in first differences. Lag length selection for the VAR model was conducted using multiple information criteria. The Akaike Information Criterion (AIC) and the Final Prediction Error (FPE) suggested a lag length of two, while the Hannan-Quinn (HQ) and Schwarz (SC) criteria, which penalize model complexity more strongly, selected one lag. Based on these results, VAR(1) and VAR(2) specifications were both estimated and compared.

In the VAR(1) model, the lagged value of Microsoft is statistically significant in the Amazon equation at the 5% significance level. In contrast, the lagged Amazon does not show a significant effect in the Microsoft equation. In the VAR(2) specification, the first and second lags of Microsoft are both significant in the Amazon equation, while Amazon's lags remain insignificant in explaining Microsoft. This pattern suggests a directional relationship from Microsoft to Amazon.

Stability checks indicate that both VAR models are stable and stationary. All characteristic roots lie well inside the unit circle, satisfying the stability condition. Diagnostic testing further supports model adequacy, serial correlation tests fail to reject the null hypothesis of white-noise residuals for both VAR(1) and VAR(2), indicating no remaining autocorrelation. Since the stricter information criteria favor the model with one lag, the VAR(1) model is chosen as the final model.

Granger causality tests based on the VAR(1) model show that Microsoft Granger-causes Amazon at the 5% significance level, while the reverse causality is non-significant. The impulse response functions align with these findings. A shock to Microsoft generates an immediate and noticeable response in Amazon's returns. This effect is short-lived, as the response quickly converges back to zero within a few periods. In the very short run, the confidence intervals do not fully include zero, indicating that the response is statistically significant. In contrast, a shock to Amazon does not produce a statistically significant response in Microsoft's prices, since confidence intervals consistently include zero.

![Orthogonal impulse response from d_MSFT](/Users/medvegygabor/Desktop/msft_amzn/figures/page-13-img-01-Im11.png)

![Orthogonal impulse response from d_AMZN](/Users/medvegygabor/Desktop/msft_amzn/figures/page-13-img-02-Im12.png)

*Figure 6. The Impulse Response Functions on the log returns of Amazon and Microsoft.*

| Period | Microsoft d_MSFT | Microsoft d_AMZN | Amazon d_MSFT | Amazon d_AMZN |
| --- | ---: | ---: | ---: | ---: |
| 1 | 1.00 | 0.0000000000 | 0.3825625 | 0.6174375 |
| 2 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |
| 3 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |
| 4 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |
| 5 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |
| 6 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |
| 7 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |
| 8 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |
| 9 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |
| 10 | 1.00 | 0.0000000131 | 0.3875398 | 0.6124602 |

Forecast error variance decomposition further confirms this asymmetry, shocks to Microsoft explain almost none of the forecast error variance in Microsoft itself, meaning that Microsoft's stock prices are primarily driven by its own past and are unaffected by Amazon. On the other hand, approximately 38-39% of the forecast error variance of Amazon is explained by shocks to Microsoft. This indicates that changes in Microsoft's stock returns have a significant impact on Amazon, but the reverse is not true.

## Conclusion

The goal of this study was to examine whether Microsoft and Amazon stock prices move together and whether their movements can be forecasted. Specifically, the analysis focused on identifying short-run interactions, potential predictive relationships, and the presence of any long-run co-movement between the two stocks. A thorough time series analysis was done, involving testing for stationarity, Box-Jenkins modeling, Engle-Granger cointegration test, as well as Vector Autoregressive (VAR) modeling, using Microsoft and Amazon stock prices from January 2023 through 2025.

The experimental results indicate that both Microsoft and Amazon have non-stationary stock price series, and these series become stationary after first differencing, hence, both Microsoft and Amazon are I(1) processes. The analysis of the differenced series using the Box-Jenkins procedure also does not show any significant autoregressive and moving average parameters, and this indicates that the daily return series for both companies are largely white noise processes.

These tests for cointegration have unanimously shown that there is no long-run equilibrium relationship between Microsoft and Amazon stock prices. This indicates that even though both companies operate in relatively similar sectors and are affected in a similar manner by macroeconomic and technological factors, they do not share a common long-run stochastic process. Their behavior in terms of stock prices is therefore not governed by a common long-run component.

As there was no cointegration among the series, the short-run dynamics were examined through a VAR model on first differenced series. The VAR model results reveal a clear asymmetry in the relationship between the two stocks. Microsoft's past returns have significant predictive power for Amazon's price, while Amazon's past prices do not significantly affect Microsoft. This was confirmed through Granger causality tests, Impulse Responses, and Forecast Error Variance Decomposition. Microsoft was observed to have a short-term, highly significant impact on Amazon, however, Amazon was found to have no significant influence on Microsoft.

Moreover, a major portion (38-39%) of the forecast error variance of Amazon was accounted for by the innovations coming from Microsoft, whereas the entire variance of Microsoft was accounted for by its innovations. However, as explained in the dataset description chapter, in the VAR framework Microsoft was ordered before Amazon, already implying from the start that Microsoft innovations have a contemporaneous effect on Amazon, while possible Amazon innovations affect Microsoft with only a lag. This was motivated by Microsoft's role as a dominant technology firm, whose market shocks plausibly influence other major tech firms as well. While some results are conditional on this assumption, the dominance of Microsoft is also evidenced by the Granger causality tests, which are invariant to variable ordering.

In summary, my findings indicate that the role of Microsoft is comparatively dominant in the short-term dynamic relationships between the two stock prices. It has been observed that there is asymmetry, which corresponds to Microsoft's significant role in the corporate world of technology and cloud infrastructure integration, which can affect the technology market expectations and, consequently, the stock price of Amazon. The observations indicate that even though Microsoft and Amazon stocks do not necessarily move together, the short-term information and shock from Microsoft affect the Amazon stock price. These observations will be beneficial to the world of technology to understand the dependencies among the major technology stocks properly.

## References

- Amazon Web Services. (2024, February 28). *AWS recognized as a first-time leader in the 2024 Gartner Magic Quadrant for data science and machine learning platforms.* AWS Machine Learning Blog. Retrieved December 29, 2025, from https://aws.amazon.com/blogs/machine-learning/aws-recognized-as-a-first-time-leader-in-the-2024-gartner-magic-quadrant-for-data-science-and-machine-learning-platforms
- Aptech Systems. (2021, May 6). *The intuition behind impulse response functions and forecast error variance decomposition.* Aptech. Retrieved December 29, 2025, from https://www.aptech.com/blog/the-intuition-behind-impulse-response-functions-and-forecast-error-variance-decomposition/
- Box, G. E. P., Jenkins, G. M., Reinsel, G. C., & Ljung, G. M. (2015). *Time series analysis: Forecasting and control* (5th ed.). Wiley.
- Clarke, H. D., & Granato, J. (2005). Time series analysis in political science. In K. Kempf-Leonard (Ed.), *Encyclopedia of social measurement* (Vol. 3, pp. 829-837). Elsevier. https://doi.org/10.1016/B0-12-369398-5/00321-2
- Engle, R. F., & Granger, C. W. J. (1987). Co-integration and error correction: Representation, estimation, and testing. *Econometrica, 55*(2), 251-276. https://doi.org/10.2307/1913236
- Fuller, W. A. (1996). *Introduction to statistical time series* (2nd ed.). John Wiley & Sons.
- Granger, C. W. J., & Newbold, P. (1974). Spurious regressions in econometrics. *Journal of Econometrics, 2*, 111-120. https://doi.org/10.1016/0304-4076(74)90034-7
- Hamilton, J. D. (1994). *Time series analysis.* Princeton University Press. https://doi.org/10.1515/9780691218632
- Kwiatkowski, D., Phillips, P. C. B., Schmidt, P., & Shin, Y. (1992). Testing the null hypothesis of stationarity against the alternative of a unit root. *Journal of Econometrics, 54*, 159-178.
- Lütkepohl, H. (2005). *New introduction to multiple time series analysis.* Springer. https://doi.org/10.1007-3-540-27752-1
- Microsoft. (2023, March 16). *Azure OpenAI Service powers the Microsoft Copilot ecosystem.* Microsoft Azure Blog. Retrieved December 29, 2025, from https://azure.microsoft.com/en-us/blog/azure-openai-service-powers-the-microsoft-copilot-ecosystem/
- Microsoft. (2025, January 15). *Scaling generative AI in the cloud: Enterprise use cases for driving secure innovation.* Microsoft Azure Blog. Retrieved December 29, 2025, from https://azure.microsoft.com/en-us/blog/scaling-generative-ai-in-the-cloud-enterprise-use-cases-for-driving-secure-innovation/
- OpenAI. (2023, January 23). *OpenAI and Microsoft extend partnership.* OpenAI. Retrieved December 29, 2025, from https://openai.com/index/openai-and-microsoft-extend-partnership
- OpenAI. (2025, November 3). *AWS and OpenAI partnership.* OpenAI. Retrieved December 29, 2025, from https://openai.com/index/aws-and-openai-partnership
- Yahoo Finance. (2025a). *Amazon.com, Inc. (AMZN) Stock Price, Quote, History & News.* YahooFinance. Retrieved December 29, 2025, from https://finance.yahoo.com/quote/AMZN/
- Yahoo Finance. (2025b). *Microsoft Corporation (MSFT) Stock Price, Quote, History & News Yahoo Finance.* YahooFinance. Retrieved December 29, 2025, from https://finance.yahoo.com/quote/MSFT/
