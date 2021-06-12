import pandas as pd
from io import StringIO
import requests


def get_csv(url):
    """sets the headers and downloads data in csv format
    
    the AEMO web server doesn't like the default python headers

    skip the first row and derive column names from the second row of data
    """
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.76 Safari/537.36'}
    s = requests.get(url, headers= headers).text
    c = pd.read_csv(StringIO(s), header=1)
    return(c)


# get the 2021 data
aemo_data_2021_df = pd.read_csv('http://www.nemweb.com.au/Reports/CURRENT/CDEII/CO2EII_SUMMARY_RESULTS.CSV', header=1)

# get the rest of the years' data 

# this tranche have dates in ymd hms format
aemo_data_2020_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2020/CO2EII_SUMMARY_RESULTS_2020.CSV')
aemo_data_2019_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2019/CO2EII_SUMMARY_RESULTS_2019.CSV')
aemo_data_2018_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2018/CO2EII_SUMMARY_RESULTS_2018.CSV')
aemo_data_2014_a_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2014/CO2EII_SUMMARY_RESULTS_2014_PT2.CSV')
aemo_data_2014_b_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2014/CO2EII_SUMMARY_RESULTS_2014_PT1.CSV')
aemo_data_2013_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2013/CO2EII_SUMMARY_RESULTS_2013.CSV')
aemo_data_2012_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2012/CO2EII_SUMMARY_RESULTS_2012.CSV')
aemo_data_2011_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2011/CO2EII_SUMMARY_RESULTS_2011.CSV')

# the next tranche have dates in dmy hm format
aemo_data_2017_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2017/CO2EII_SUMMARY_RESULTS_2017.CSV')
aemo_data_2016_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2016/CO2EII_SUMMARY_RESULTS_2016.csv')
aemo_data_2015_df = get_csv('http://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2015/CDEII-20160105.csv')

# convert date as strings to date dtype

# first tranche are ymd hms
aemo_data_2021_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2021_df['SETTLEMENTDATE'])
aemo_data_2020_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2020_df['SETTLEMENTDATE'])
aemo_data_2019_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2019_df['SETTLEMENTDATE'])
aemo_data_2018_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2018_df['SETTLEMENTDATE'])
aemo_data_2014_a_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2014_a_df['SETTLEMENTDATE'])
aemo_data_2014_b_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2014_b_df['SETTLEMENTDATE'])
aemo_data_2013_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2013_df['SETTLEMENTDATE'])
aemo_data_2012_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2012_df['SETTLEMENTDATE'])
aemo_data_2011_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2011_df['SETTLEMENTDATE'])

# second tranche are dmy hms 
aemo_data_2017_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2017_df['SETTLEMENTDATE'])
aemo_data_2016_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2016_df['SETTLEMENTDATE'])
aemo_data_2015_df['SETTLEMENTDATE'] = pd.to_datetime(aemo_data_2015_df['SETTLEMENTDATE'])

merge_list = [aemo_data_2021_df, aemo_data_2020_df, aemo_data_2019_df, aemo_data_2018_df, aemo_data_2017_df, aemo_data_2016_df, aemo_data_2015_df, aemo_data_2014_a_df, aemo_data_2014_b_df, aemo_data_2013_df, aemo_data_2012_df, aemo_data_2011_df]

# merge all together
aemo_data_merged_df = pd.concat(merge_list)

# # data conditioning and cleanup
# aemo_data_merged_df.dtypes

# aemo_data_merged_df.head(5)

# aemo_data_merged_df['I'].unique()
# aemo_data_merged_df['CO2EII'].unique()


# # what is I = C?
# aemo_data_merged_df[aemo_data_merged_df['I'] == 'C']

# looks like end of report data, so let's just filter for I = D (D must mean data)
aemo_data_merged_df = aemo_data_merged_df[aemo_data_merged_df['I'] == 'D']
 
# remove unwanted columns 
aemo_data_merged_df.drop(columns=['I', 'CO2EII', 'PUBLISHING', '1', 'CONTRACTYEAR', 'WEEKNO'], inplace=True)

# save to a file 
aemo_data_merged_df.to_csv('data/aemo_data_merged.csv', index=False)
