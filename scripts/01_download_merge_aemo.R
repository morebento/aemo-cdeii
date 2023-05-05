#'  01_download_merge_aemo.R
#'   
#'  script to cdownload and merge data from AEMO CO2e Intensity Index  
#'


# Libraries --------

library(tidyverse)
library(rvest)
library(janitor)
library(lubridate)



# Functions --------------

read_aemo_ymd_hms <- function(url) {
    # reads AEMO CDEII data in ymd_mhs datestamp format
    data_tbl <- read_csv(url, skip = 1) %>%
        clean_names() %>%
        mutate(settlementdate = ymd_hms(settlementdate))
    
    return(data_tbl)
}


read_aemo_dmy_hm <- function(url) {
    # reads AEMO CDEII data in dmy_hm format
    data_tbl <- read_csv(url, skip=1) %>%
        clean_names() %>%
        mutate(settlementdate = dmy_hm(settlementdate))
}


# Gather --------------------------

# AEMO CO2EII data 


# get current year's data. this is from the current URL http://nemweb.com.au/Reports/Current/CDEII/
aemo_data_current_tbl <- read_aemo_ymd_hms("http://www.nemweb.com.au/Reports/CURRENT/CDEII/CO2EII_SUMMARY_RESULTS.CSV") 


# get the previous years' data - this is from the archive directory

# this tranche have dates in hms format
aemo_data_2022_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2020/CO2EII_SUMMARY_RESULTS_2020.CSV")
aemo_data_2021_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2020/CO2EII_SUMMARY_RESULTS_2020.CSV")
aemo_data_2020_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2020/CO2EII_SUMMARY_RESULTS_2020.CSV")
aemo_data_2019_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2019/CO2EII_SUMMARY_RESULTS_2019.CSV")
aemo_data_2018_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2018/CO2EII_SUMMARY_RESULTS_2018.CSV")
aemo_data_2014_a_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2014/CO2EII_SUMMARY_RESULTS_2014_PT2.CSV")
aemo_data_2014_b_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2014/CO2EII_SUMMARY_RESULTS_2014_PT1.CSV")
aemo_data_2013_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2013/CO2EII_SUMMARY_RESULTS_2013.CSV")
aemo_data_2012_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2012/CO2EII_SUMMARY_RESULTS_2012.CSV")
aemo_data_2011_tbl <- read_aemo_ymd_hms("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2011/CO2EII_SUMMARY_RESULTS_2011.CSV")

# the next tranche have dates in dmy hm format
aemo_data_2017_tbl <- read_aemo_dmy_hm("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2017/CO2EII_SUMMARY_RESULTS_2017.CSV")
aemo_data_2016_tbl <- read_aemo_dmy_hm("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2016/CO2EII_SUMMARY_RESULTS_2016.csv")
aemo_data_2015_tbl <- read_aemo_dmy_hm("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2015/CDEII-20160105.csv")


# Tidy ----------------

# combine
aemo_combined_tbl <- bind_rows(
                          aemo_data_2011_tbl, 
                          aemo_data_2012_tbl, 
                          aemo_data_2013_tbl, 
                          aemo_data_2014_a_tbl, 
                          aemo_data_2014_b_tbl, 
                          aemo_data_2015_tbl, 
                          aemo_data_2016_tbl, 
                          aemo_data_2017_tbl, 
                          aemo_data_2018_tbl, 
                          aemo_data_2019_tbl,
                          aemo_data_2020_tbl,
                          aemo_data_2021_tbl,
                          aemo_data_2022_tbl,
                          aemo_data_current_tbl,
                          ) %>% 
    drop_na() %>%
    select(-i, -co2eii, -publishing, -x1,  -weekno, -contractyear) %>%
    mutate(
        settlementdate = as_date(settlementdate)
    )

# Export ------------------------------------------------------------------

write_rds(aemo_combined_tbl, "data/cdeii_2011_to_current.rds")


