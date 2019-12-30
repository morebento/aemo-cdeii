#' cdeii.R 
#'
#' script to download, expore and chart cdeii data
#'

library(tidyverse)
library(rvest)
library(xml2)
library(janitor)
library(lubridate)
library(tidyquant)
library(anomalize)
library(timetk)

# Configure ---------------------------------------------------------------



cdeii_url <- "https://www.aemo.com.au/Electricity/National-Electricity-Market-NEM/Settlements-and-payments/Settlements/Carbon-Dioxide-Equivalent-Intensity-Index"


# Gather Data -------------------------------------------------------------

# ymd 
# get current year's data
data_2019_tbl <- read_csv("http://www.nemweb.com.au/Reports/CURRENT/CDEII/CO2EII_SUMMARY_RESULTS.CSV", skip = 1) %>%
    clean_names() %>%
    mutate(settlementdate = ymd_hms(settlementdate))


data_2018_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2018/CO2EII_SUMMARY_RESULTS_2018.CSV", skip=1) %>%
    clean_names() %>%
    mutate(settlementdate = ymd_hms(settlementdate))

data_2014_a_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2014/CO2EII_SUMMARY_RESULTS_2014_PT2.CSV", skip = 1) %>%
    clean_names() %>%
    mutate(settlementdate = ymd_hms(settlementdate))

data_2014_b_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2014/CO2EII_SUMMARY_RESULTS_2014_PT1.CSV", skip = 1) %>%
    clean_names() %>%
    mutate(settlementdate = ymd_hms(settlementdate))

data_2013_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2013/CO2EII_SUMMARY_RESULTS_2013.CSV", skip = 1) %>%
    clean_names() %>%
    mutate(settlementdate = ymd_hms(settlementdate))

data_2012_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2012/CO2EII_SUMMARY_RESULTS_2012.CSV", skip = 1) %>%
    clean_names() %>%
    mutate(settlementdate = ymd_hms(settlementdate))

data_2011_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2011/CO2EII_SUMMARY_RESULTS_2011.CSV", skip = 1) %>%
    clean_names() %>%
    mutate(settlementdate = ymd_hms(settlementdate))

# dmy

data_2017_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2017/CO2EII_SUMMARY_RESULTS_2017.CSV", skip=1) %>%
    clean_names() %>%
    mutate(settlementdate = dmy_hm(settlementdate))


data_2016_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2016/CO2EII_SUMMARY_RESULTS_2016.csv", skip = 1) %>%
    clean_names() %>%
    mutate(settlementdate = dmy_hm(settlementdate))


data_2015_tbl <- read_csv("https://www.aemo.com.au/-/media/Files/Electricity/NEM/Settlements_and_Payments/Settlements/2015/CDEII-20160105.csv", skip = 1) %>%
    clean_names() %>%
    mutate(settlementdate = dmy_hm(settlementdate))


# Explore -----------------------------------------------------------------




# Tidy --------------------------------------------------------------------

# combine
combined_tbl <- bind_rows(data_2011_tbl, data_2012_tbl, data_2013_tbl, 
                          data_2014_a_tbl, data_2014_b_tbl, data_2015_tbl, 
                          data_2016_tbl, data_2017_tbl, data_2018_tbl, data_2019_tbl) %>% 
    drop_na() %>%
    select(-i, -co2eii, -publishing, -x1) %>%
    mutate(
        settlementdate = as_date(settlementdate)
    )


# Explore -----------------------------------------------------------------

combined_tbl %>% glimpse()

combined_tbl %>%
    summarise(
        max_date = max(settlementdate),
        min_date = min(settlementdate)
    )


# Plot --------------------------------------------------------------------

combined_tbl %>%
    filter(regionid == "SA1") %>%
    arrange(settlementdate) %>%
    ggplot(aes(settlementdate, co2e_intensity_index)) +
    geom_line(colour=palette_light()[[1]]) +
    geom_vline(xintercept = dmy("09/05/2016"), colour = palette_light()[[2]], size=1) +
    geom_smooth(
        data = combined_tbl %>% 
                filter(
                    regionid == "SA1", 
                    settlementdate >  dmy("09/05/2016")       
                ),
        #se=FALSE,
        fill = palette_light()[[6]],
        alpha=0.4,
        colour = palette_light()[[6]]
    ) +
    geom_smooth(
        data = combined_tbl %>% 
            filter(
                regionid == "SA1", 
                settlementdate <  dmy("09/05/2016")       
            ),
        #se=FALSE,
        fill = palette_light()[[7]],
        alpha=0.4,
        colour = palette_light()[[7]]
    ) +
    labs(
        title = "AEMO CDEII: Daily CO2e Intensity Index for South Australia NEM Region",
        subtitle = str_glue("Red line:  9 May 2016 shutdown of Northern Power Station
                             Green line: GAM smoother for pre Northern shutdown
                             Blue line: GAM model for post Northern shutdown"),
        x = "Settlement Date",
        y = "CO2e Intensity Index (t CO2-e /MWh)",
        caption = "@morebento"
    ) +
    theme_tq() 


# same with total emissions
combined_tbl %>%
    filter(regionid == "SA1") %>%
    arrange(settlementdate) %>%
    ggplot(aes(settlementdate, total_emissions)) +
    geom_line(colour=palette_light()[[1]]) +
    geom_vline(xintercept = dmy("09/05/2016"), colour = palette_light()[[2]], size=1) +
    geom_smooth(
        data = combined_tbl %>% 
            filter(
                regionid == "SA1", 
                settlementdate >  dmy("09/05/2016")       
            ),
        #se=FALSE,
        fill = palette_light()[[6]],
        alpha=0.4,
        colour = palette_light()[[6]]
    ) +
    geom_smooth(
        data = combined_tbl %>% 
            filter(
                regionid == "SA1", 
                settlementdate <  dmy("09/05/2016")       
            ),
        #se=FALSE,
        fill = palette_light()[[7]],
        alpha=0.4,
        colour = palette_light()[[7]]
    ) +
    labs(
        title = "AEMO CDEII: Daily Total Emissions (Tonnes CO2e) for South Australia NEM Region",
        subtitle = str_glue("Red line:  9 May 2016 shutdown of Northern Power Station
                             Green line: GAM smoother for pre Northern shutdown
                             Blue line: GAM model for post Northern shutdown"),
        x = "Settlement Date",
        y = "Daily Total Emissions (Tonnes CO2e)",
        caption = "@morebento"
    ) +
    theme_tq() 


# multiple boxplot at monthly aggregate
combined_tbl %>%
    filter(regionid == "SA1") %>%
    mutate(
        northern_shutdown  = if_else(settlementdate >  dmy("09/05/2016"), "Yes", "No"),
        month = lubridate::floor_date(settlementdate, "month"),
        quarter = lubridate::floor_date(settlementdate, "quarter")
    ) %>%
    ggplot(aes(month, co2e_intensity_index)) +
    geom_boxplot(aes(group=quarter, colour=northern_shutdown)) +
    theme_tq() +
    scale_colour_tq() 

combined_tbl %>% distinct(regionid)

combined_tbl %>%
    filter(regionid == "SA1") %>%
    #filter(settlementdate >  dmy("09/05/2016")) %>%
    time_decompose(co2e_intensity_index) %>%
    anomalize(remainder) %>%
    plot_anomaly_decomposition() +
    labs(
        title = "AEMO CDEII: Daily CO2e Intensity Index for South Australia NEM Region",
        subtitle = str_glue("STL based time decomposition with IQR anomaly detection"),
        x = "Settlement Date",
        y = "",
        caption = "@morebento"
    )  +
    theme(
        legend.position = "none"
    )





# prepare for plotting
data_plotting_tbl <- combined_tbl %>% 
    select(settlementdate:co2e_intensity_index, contractyear) %>%
    gather(measure, value, -settlementdate, -regionid, -contractyear) %>%
    mutate(
        measure = str_replace_all(measure, "_", " "),
        measure = str_to_title(measure)
    ) %>%
    filter(regionid != "NEM") 


# time series
data_plotting_tbl %>%
    ggplot(aes(settlementdate, value)) +
    geom_line(aes(colour=measure)) +
    facet_grid(cols = vars(regionid), rows = vars(measure), scales="free_y") +
    theme_tq() +
    scale_colour_tq() +
    labs(
        title = "AEMO Carbon Dioxide Equivalent Intensity Index (CDEII)",
        subtitle = str_glue("Source: {cdeii_url}"),
        x = "Date",
        y = "",
        caption = "@morebento"
    )

# histogramn
data_plotting_tbl %>% 
    mutate(
        contractyear = as_factor(contractyear)
    ) %>%
    ggplot(aes(value)) +
    geom_histogram(aes(fill=contractyear)) +
    facet_grid(rows = vars(regionid), cols = vars(measure), scales="free_x") +
    theme_tq() +
    scale_fill_tq() +
    labs(
        title = "AEMO Carbon Dioxide Equivalent Intensity Index (CDEII)",
        subtitle = str_glue("Histograms
                             Year: Current (2019),
                             Source: {cdeii_url}"),
        x = "",
        y = "Count",
        caption = "@morebento"
    )
    
# box plot
data_plotting_tbl %>%
    ggplot(aes(regionid, value)) +
    #geom_violin(aes(fill=regionid)) +
    geom_boxplot(aes(colour=regionid)) +
    facet_wrap(vars(measure), scales="free") +
    theme_tq() +
    scale_colour_tq() +
    labs(
        title = "AEMO Carbon Dioxide Equivalent Intensity Index (CDEII)",
        subtitle = str_glue("Violin Plots
                             Year: Current (2019),
                             Source: {cdeii_url}"),
        x = "",
        y = "",
        caption = "@morebento"
    ) +
    theme(
        legend.position = "none"
    )

# sa cdeii plot - time deocomposed 
combined_tbl %>%
    group_by(regionid) %>%
    filter(regionid == "SA1") %>%
    #filter(settlementdate >  dmy("09/05/2016")) %>%
    arrange(settlementdate) %>%
    time_decompose(co2e_intensity_index) %>%
    #time_decompose(total_emissions) %>%
    #anomalize(remainder) %>%
    #filter(anomaly == "No") %>%
    timetk::tk_augment_timeseries_signature() %>%
    ggplot(aes(settlementdate, trend)) +
    geom_line(aes(colour=regionid)) +
    #geom_point(aes(colour=anomaly)) +
    facet_wrap(vars(regionid)) +
    theme_tq() +
    scale_colour_tq() +
    labs(
        title = "AEMO Carbon Dioxide Equivalent Intensity Index (CDEII)",
        subtitle = str_glue("SA1 Region
                             Time Decomposed Trend"),
        x = "",
        y = "",
        caption = "@morebento"
    ) +
    theme(
        legend.position = "none"
    )
        
        
        

# Model -----------------------------------------------------------------

library(sweep)
library(forecast)

sa_no_coal_tbl <- combined_tbl %>%
    filter(
        regionid == "SA1",
        settlementdate >  dmy("09/05/2016")
    ) %>%
    select(settlementdate, co2e_intensity_index) 

sa_no_coal_tbl %>%
    summarise(min = min(settlementdate), max=max(settlementdate))

tk_ts(sa_no_coal_tbl, start )

