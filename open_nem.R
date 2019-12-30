library(tidyverse)
library(janitor)
library(lubridate)
library(tidyquant)


sa_open_nem_tbl <- read_csv("20181231 South Australia.csv") %>% 
    clean_names() %>%
    select(date:temperature_max_c) %>%
    mutate(date = as_date(date))

sa_open_nem_tbl %>% glimpse()

sa_open_nem_tbl %>%
    gather(attribute, value, -date) %>%
    filter(! str_detect(attribute, "temperature_")) %>%
    ggplot(aes(date, value)) +
    geom_line(aes(colour=attribute)) +
    facet_wrap(vars(attribute)) +
    theme_tq() +
    scale_colour_tq()


combined_cdeii_tbl <- read_rds("combined_cdeii.rds") %>%
    filter(regionid == "SA1") %>%
    inner_join(sa_open_nem_tbl, by = c("settlementdate"="date")) %>%
    select(-contractyear, -weekno, -regionid, -total_emissions, -total_sent_out_energy) 

combined_cdeii_tbl %>% glimpse()

combined_cdeii_tbl %>%
    #timetk::tk_augment_timeseries_signature() %>%
    select(-settlementdate) %>%
    GGally::ggpairs()

combined_cdeii_tbl %>%
    select(co2e_intensity_index:battery_charging_g_wh) %>%
    gather(generation, value, -co2e_intensity_index) %>%
    ggplot(aes(co2e_intensity_index, value)) +
    geom_point(aes(colour=generation)) +
    facet_wrap(vars(generation), scales="free") +
    theme_tq() +
    scale_colour_tq()
