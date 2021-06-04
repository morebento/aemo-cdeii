
library(tidyverse)

# read the combined sa aemo / open nem data
sa_combined_aemo_opennem_tbl <- read_rds("data/sa_combined_aemo_opennem.rds")

sa_combined_aemo_opennem_tbl %>% glimpse()

sa_combined_aemo_opennem_tbl %>% count()

sa_combined_aemo_opennem_tbl %>%
    summarise(
        max_date = max(settlementdate),
        min_date = min(settlementdate)
    )


# time series plot
sa_combined_aemo_opennem_tbl %>%
    pivot_longer(!settlementdate, names_to="metric", values_to="value") %>%
    ggplot(aes(settlementdate, value)) +
    facet_wrap(vars(metric), scales="free_y") +
    geom_line(aes(colour=metric)) +
    labs(
        title = "SA Various Generator Metrics vs Time",
        subtitle = "Data derived from AEMO and Open NEM, 29 May 2020 to 22 May 2021",
        caption = "1 June 2021 @morebento",
        x = "Date",
        y = "Metric Value",
        colour = "Metric"
    )


# everything vs co2e_intensity_index
sa_combined_aemo_opennem_tbl %>%
    select(-settlementdate) %>%
    pivot_longer(!co2e_intensity_index, names_to="metric", values_to="value") %>%
    ggplot(aes(co2e_intensity_index, value)) +
    facet_wrap(vars(metric), scales="free_y") +
    geom_point(aes(colour=metric)) +
    geom_smooth() +
    labs(
        title = "SA CO2e Intensity Index vs Various Generator Metrics",
        subtitle = "Data derived from AEMO and Open NEM, 29 May 2020 to 22 May 2021",
        caption = "1 June 2021 @morebento",
        x = "CO2e Intensity Index",
        y = "Metric Value",
        colour = "Metric"
    )

# look at wind vs gas steaming
sa_combined_aemo_opennem_tbl %>%
    ggplot(aes(wind_g_wh, gas_steam_g_wh)) +
    geom_point(aes(colour=temperature_mean_c)) +
    geom_smooth()

