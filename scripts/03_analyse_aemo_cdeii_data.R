library(tidyverse)
library(anomalize)
library(tibbletime)


aemo_cdeii_tbl <- read_rds("data/cdeii_2011_to_2021.rds")

aemo_cdeii_tbl %>% glimpse()

# plot all metrics vs time
aemo_cdeii_tbl %>%
    pivot_longer(!c(settlementdate, regionid), names_to = "metric", values_to = "value") %>%
    filter(regionid != "NEM") %>%
    ggplot(aes(settlementdate, value)) +
    geom_line(aes(colour=regionid)) +
    facet_grid(cols=vars(regionid), rows=vars(metric), scales = "free") +
    labs(
        title = "Merged AEMO CO2e Intensity Index Data for Australian NEM",
        subtitle = "Source: www.aemo.com.au",
        x = "Date",
        y = "Metric Value",
        colour = "Region",
        caption = "1 June 2021, @morebento"
    )


# handle seasonality and anomalies
aemo_cdeii_anomalised_tbl <- aemo_cdeii_tbl %>%
    #filter(regionid == "SA1") %>%
    group_by(regionid) %>%
    select(settlementdate, co2e_intensity_index) %>%
    time_decompose(co2e_intensity_index) %>%
    anomalize(remainder) %>%
    time_recompose() %>%
    ungroup() 

# auto plot for SA
aemo_cdeii_anomalised_tbl %>%
    filter(regionid == "SA1") %>%
    plot_anomaly_decomposition() +
    ggtitle("SA CO2e Intensity Index Seasonal Decomposition + Anomaly Detection")


# plot all trends
aemo_cdeii_anomalised_tbl %>%
    filter(anomaly == "No") %>%
    ggplot(aes(settlementdate, trend)) +
    geom_line() +
    facet_wrap(vars(regionid))

# plot all trends
aemo_cdeii_anomalised_tbl %>%
    select(regionid, settlementdate, observed, season, trend, remainder, anomaly) %>%
    pivot_longer(!c(regionid, settlementdate, anomaly), names_to="metric", values_to="value") %>%

    ggplot(aes(settlementdate, value)) +
    geom_line(aes(colour=metric)) +
    facet_grid(rows=vars(metric), cols=vars(regionid), scales="free_y") +
    labs(
        title = "Merged AEMO CO2e Intensity Index Data for Australian NEM",
        subtitle = "Seasonal Decomposition. Source: www.aemo.com.au",
        x = "Date",
        y = "Metric Value",
        colour = "Metric",
        caption = "1 June 2021, @morebento"
    )

aemo_cdeii_anomalised_tbl %>%
    ggplot(aes(settlementdate, trend)) +
    geom_line(aes(colour=regionid)) +
    labs(
        title = "Merged AEMO CO2e Intensity Index Data for Australian NEM",
        subtitle = "Seasonally Decomposed Trend for All Regions. Source: www.aemo.com.au",
        x = "Date",
        y = "Trend Value (CO2e Intensity Index)",
        colour = "Region",
        caption = "1 June 2021, @morebento"
    )
