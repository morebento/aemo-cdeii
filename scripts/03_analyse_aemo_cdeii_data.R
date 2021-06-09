#' does some initial analysis of the aemo cdeii data

# libraries ---------

library(tidyverse)
library(anomalize)
library(tibbletime)
library(tidyquant)

# import data --------

aemo_cdeii_tbl <- read_rds("data/cdeii_2011_to_2021.rds")

# explore data -------

aemo_cdeii_tbl %>% glimpse()

# visualise ------

# plot all metrics vs time
aemo_cdeii_metrics_plot <- aemo_cdeii_tbl %>%
    pivot_longer(!c(settlementdate, regionid), names_to = "metric", values_to = "value") %>%
    filter(regionid != "NEM") %>%
    ggplot(aes(settlementdate, value)) +
    geom_line(aes(colour=regionid)) +
    facet_grid(cols=vars(regionid), rows=vars(metric), scales = "free") +
    theme_tq() +
    scale_colour_tq() +
    labs(
        title = "Merged AEMO CO2e Intensity Index Data for Australian NEM",
        subtitle = "Source: www.aemo.com.au",
        x = "Date",
        y = "Metric Value",
        colour = "Region",
        caption = "1 June 2021, @morebento"
    )

# save the png
ggsave(
    filename = "plots/aemo_cdeii_metrics_plot.png", 
    plot = aemo_cdeii_metrics_plot,
    height = 210,
    width = 297,
    units = "mm"
)


# handle seasonality and anomalies
aemo_cdeii_deanomalised_tbl <- aemo_cdeii_tbl %>%
    group_by(regionid) %>%
    select(settlementdate, co2e_intensity_index) %>%
    time_decompose(co2e_intensity_index) %>%
    anomalize(remainder) %>%
    time_recompose() %>%
    ungroup() 


# plot all trends 
aemo_cdeii_deanomalised_plot <- aemo_cdeii_deanomalised_tbl %>%
    ggplot(aes(settlementdate, trend)) +
    geom_line(aes(colour=regionid)) +
    theme_tq() +
    scale_colour_tq() +
    labs(
        title = "Merged AEMO CO2e Intensity Index Data for Australian NEM",
        subtitle = "Seasonally Decomposed Trend for All Regions. Source: www.aemo.com.au",
        x = "Date",
        y = "Trend Value (CO2e Intensity Index)",
        colour = "Region",
        caption = "1 June 2021, @morebento"
    )

# save the png
ggsave(
    filename = "plots/aemo_cdeii_deanomalised_plot.png", 
    plot = aemo_cdeii_deanomalised_plot,
    height = 210,
    width = 297,
    units = "mm"
)
