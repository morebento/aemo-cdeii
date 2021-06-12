import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import statsmodels.api as sm

# import data
aemo_data_df = pd.read_csv('aemo_data_merged.csv')

# preview
aemo_data_df.head(5)

aemo_data_df.dtypes

# plot all metrics vs time broken up by region
sa_cdeii_df = aemo_data_df[aemo_data_df['REGIONID'] == 'SA1'][['SETTLEMENTDATE', 'CO2E_INTENSITY_INDEX']]

sa_cdeii_df.plot()

# unpivot the data 
aemo_data_melted_df = pd.melt(aemo_data_df, id_vars=['SETTLEMENTDATE', 'REGIONID'], value_vars=['TOTAL_SENT_OUT_ENERGY', 'TOTAL_EMISSIONS', 'CO2E_INTENSITY_INDEX'])

sa_cdeii_df.set_index(['SETTLEMENTDATE'], inplace=True)

sa_cdeii_df.plot() 
plt.title('SA CO2e Intensity Index')

aemo_data_pivoted_df = pd.pivot_table(aemo_data_df[['SETTLEMENTDATE', 'REGIONID', 'CO2E_INTENSITY_INDEX']], values='CO2E_INTENSITY_INDEX', index=['SETTLEMENTDATE'], columns=['REGIONID']) 

fig, axes = plt.subplots(nrows=2, ncols=3)

aemo_data_pivoted_df['NEM'].plot(ax=axes[0,0])
aemo_data_pivoted_df['NSW1'].plot(ax=axes[0,1])
aemo_data_pivoted_df['QLD1'].plot(ax=axes[0,2])

aemo_data_pivoted_df['SA1'].plot(ax=axes[1,0])
aemo_data_pivoted_df['TAS1'].plot(ax=axes[1,1])
aemo_data_pivoted_df['VIC1'].plot(ax=axes[1,2])

# handle seasonality
from statsmodels.tsa.seasonal import seasonal_decompose
aemo_data_pivoted_df['SA1'].rolling(90, center=True).mean().plot()

res = seasonal_decompose(aemo_data_pivoted_df['SA1'], model='multiplicative', period=365)

res.trend.plot()
res.seasonal.plot()
res.resid.plot()
res.observed.plot()

res.trend