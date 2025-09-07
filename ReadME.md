# ARIMA Forecasting for Stock Market Analysis: A Case Study on Bharti Airtel VWAP

This repository hosts a detailed implementation of an ARIMA (AutoRegressive Integrated Moving Average) model for analyzing and forecasting the Volume Weighted Average Price (VWAP) of Bharti Airtel stock data from the NIFTY 50 index. Developed as part of quantitative finance exploration, this project applies rigorous time series techniques in R to transform non-stationary financial data into actionable insights. It reflects extensive iterative work—including data preprocessing, multiple stationarity tests, model optimization, diagnostic validation, and forecasting accuracy assessment—to deliver a robust predictive tool. Ideal for data scientists, financial analysts, and researchers interested in econometric modeling and stock market dynamics.

## Project Overview

Financial markets generate volatile time series data, demanding sophisticated methods to detect patterns and predict trends. This project uses historical daily VWAP data from Bharti Airtel (2000–2021) to build an ARIMA model, emphasizing stationarity enforcement, residual diagnostics, and forecast validation. Key highlights include:
- Comprehensive stationarity testing with ADF, PP, and KPSS to handle non-stationarity.
- Automated ARIMA fitting refined for optimal parameters, yielding low error metrics (MAE = 0.015).
- Handling of real-world data challenges like outliers, with in-sample and out-of-sample forecasting.
- Supplementary interpretation document explaining results and limitations.

The effort involved weeks of development, from data sourcing and cleaning to model tuning and visualization, resulting in a model accurate enough for short-term predictions (MAE < 0.05).

## Dataset

- **Source**: Daily stock price and volume data for Bharti Airtel from the NIFTY 50 dataset on Kaggle (spanning January 1, 2000, to April 30, 2021).  
  Link: [Kaggle NIFTY 50 Stock Market Data](https://www.kaggle.com/datasets/rohanrao/nifty50-stock-market-data/data?select=BHARTIARTL.csv)
- **File**: `data/BHARTIARTL.xlsx` (derived from the CSV; place it in `data/` for reproduction).
- **Focus**: VWAP series used for analysis, with log-differencing applied for stationarity.

## Methodology

The analysis follows a structured pipeline, as detailed in `main.R` and the interpretation PDF:

1. **Data Import and Preparation**: Load data using `readxl` and attach for analysis.
2. **Stationarity Testing**: 
   - Plot raw VWAP and test with ADF (initial p-value = 0.948, non-stationary).
   - Apply log-differencing: `rVWAP = diff(log(VWAP))`.
   - Re-test: ADF (p-value = 0.01), PP (p-value = 0.01), KPSS (p-value = 0.08676)—all confirm stationarity.
3. **Model Selection and Fitting**:
   - Use `auto.arima` to identify ARIMA(1,0,2) with non-zero mean.
   - Fit model: Coefficients include AR(1) = 0.2702, MA(1) = -0.1646, MA(2) = -0.0919, mean = 0.0005.
   - Equation:  
     \[ rVWAP_t = 0.0005 + 0.2702 \cdot rVWAP_{t-1} - 0.1646 \cdot e_{t-1} - 0.0919 \cdot e_{t-2} \]
   - Metrics: Sigma² ≈ 0.000536, AIC = -22396.98.
4. **Diagnostic Checks**:
   - Residuals: ACF shows no autocorrelation; Box-Pierce test (p-value = 0.4776) confirms independence.
   - Normality: Shapiro-Wilk, histogram, and QQ plots indicate good fit, with minor outliers noted.
   - Zero mean and plotting confirm no systematic patterns.
5. **Forecasting and Validation**:
   - 10-step ahead forecasts with 80% and 95% confidence intervals.
   - In-sample testing on held-out data for accuracy comparison.
   - Overall accuracy: ME ≈ 0, RMSE = 0.023, MAE = 0.015 (indicating high reliability).
6. **Visualizations**: Time series plots, residual diagnostics, and forecast graphs (in `plots/`).

For a narrative walkthrough, see `INTERPRETATION-for-ARIMA.pdf`, which discusses outliers' minimal impact and model acceptability.

## Getting Started

### Prerequisites
- R (version 4.0+ recommended).
- Packages: `tseries`, `forecast`, `urca`, `fpp2`, `readxl` (install with `install.packages(c("tseries", "forecast", "urca", "fpp2", "readxl"))`).

### Installation and Usage
1. Clone the repository:  
   `git clone https://github.com/yourusername/ARIMA-BhartiAirtel-Forecasting.git`
2. Open `ARIMA.Rproj` in RStudio.
3. Ensure `data/BHARTIARTL.xlsx` is present (download from Kaggle if needed).
4. Run the main script:  
   `source('main.R')`
5. For variants or tests, use `main_test.R`.
6. Review outputs in console, plots in `plots/`, and the PDF in `toSubmit/`.

## Results and Insights

The model captures VWAP trends effectively, with forecasts converging to small positive values. Outliers introduce slight inconsistencies in residuals, but they have negligible impact on accuracy. This demonstrates ARIMA's utility for financial forecasting, potentially extendable to portfolio optimization or risk assessment.

## Limitations and Future Work
- Data spans up to 2021; real-time extensions could incorporate APIs for current data.
- Outliers affect normality slightly—future iterations might use robust ARIMA variants.
- Enhancements: Integrate seasonality (SARIMA), volatility (GARCH), or hybrid ML models (e.g., ARIMA combined with LSTM).

This project exemplifies practical time series analysis in finance, drawing from extensive testing and validation. Contributions, issues, or forks are encouraged!

License: MIT  
Author: Prabhu Nandan 
Last Updated: September 2025

