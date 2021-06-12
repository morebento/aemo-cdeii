import pandas as pd

# read aemo data previously merged
aemo_data_merged_df = pd.read_csv('../data/aemo_data_merged.csv')

# read opennem generator data
opennem_sa_df = pd.read_csv('../data/20200529 South Australia.csv')

# filter the aemo data to only give SA1 region
sa_aemo_data_merged_df = aemo_data_merged_df[aemo_data_merged_df['REGIONID'] == 'SA1']


# merge together
aemo_opennem_sa_merged_df = pd.merge(sa_aemo_data_merged_df, opennem_sa_df, left_on = 'SETTLEMENTDATE', right_on = 'date')

# save to csv
aemo_opennem_sa_merged_df.to_csv('../data/aemo_opennem_sa_merged.csv', index=False)