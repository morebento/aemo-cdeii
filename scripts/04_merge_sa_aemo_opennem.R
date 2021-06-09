#' wrangles open nem data for generation
#' 
#' 30 may 2020

# libraries ----------------------------------

library(tidyverse)
library(janitor)
library(lubridate)

# read data ------------------------------------------

# read the open nem data and clean up a bit
opennem_sa_tbl <- read_csv("data/20200529 South Australia.csv") %>% 
    clean_names() %>%
    select(date:temperature_max_c) %>%
    mutate(date = as_date(date))

# read the aemo cdeii data  
sa_combined_cdeii_tbl <- read_rds("data/cdeii_2011_to_2021.rds") %>%
    filter(regionid == "SA1") 


# tidy ----------------------------------------------

# join to the opennem data
combined_aemo_opennem_tbl <- inner_join(sa_combined_cdeii_tbl, opennem_sa_tbl, by = c("settlementdate"="date")) %>%
    select(-regionid, -total_emissions, -total_sent_out_energy) 


# export ----------------------------------------------

write_rds(combined_aemo_opennem_tbl, "data/sa_combined_aemo_opennem.rds")



