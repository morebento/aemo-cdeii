#' analyses combined aemo co2e intentisy index and open nem generator data for sa
#' 
#' looks at relationship between generator mix and cdeii

# libraries -----

library(tidyverse)
library(tidyquant)
library(timetk)

# read data ----

# read the combined sa aemo / open nem data
sa_combined_aemo_opennem_tbl <- read_rds("data/sa_combined_aemo_opennem.rds")

# explore -----

# check the data model
sa_combined_aemo_opennem_tbl %>% glimpse()

# how many records
sa_combined_aemo_opennem_tbl %>% count()

# start and end date
sa_combined_aemo_opennem_tbl %>%
    summarise(
        max_date = max(settlementdate),
        min_date = min(settlementdate)
    )

# visualise ----

# time series plot
sa_combined_aemo_opennem_plot <- sa_combined_aemo_opennem_tbl %>%
    pivot_longer(!settlementdate, names_to="metric", values_to="value") %>%
    mutate(
        metric = str_replace(metric, "g_wh", "gwh")
    ) %>%
    ggplot(aes(settlementdate, value)) +
    facet_wrap(vars(metric), scales="free_y") +
    geom_line(aes(colour=metric)) +
    theme_tq() +
    scale_colour_tq() +
    labs(
        title = "SA Various Generator Metrics vs Time",
        subtitle = "Data derived from AEMO and Open NEM, 29 May 2020 to 22 May 2021",
        caption = "1 June 2021 @morebento",
        x = "Date",
        y = "Metric Value",
        colour = "Metric"
    )

# save the png
ggsave(
    filename = "plots/sa_combined_aemo_opennem_plot.png", 
    plot = sa_combined_aemo_opennem_plot,
    height = 210,
    width = 297,
    units = "mm"
)


# everything vs co2e_intensity_index
sa_combined_aemo_opennem_plot <- sa_combined_aemo_opennem_tbl %>%
    select(-settlementdate) %>%
    pivot_longer(!co2e_intensity_index, names_to="metric", values_to="value") %>%
    ggplot(aes(co2e_intensity_index, value)) +
    facet_wrap(vars(metric), scales="free_y") +
    geom_point(aes(colour=metric)) +
    geom_smooth(se=FALSE, linetype="dashed", colour=palette_light()[[1]]) +
    theme_tq() +
    scale_colour_tq() +
    labs(
        title = "SA CO2e Intensity Index vs Various Generator Metrics",
        subtitle = "Data derived from AEMO and Open NEM, 29 May 2020 to 22 May 2021",
        caption = "1 June 2021 @morebento",
        x = "CO2e Intensity Index",
        y = "Metric Value",
        colour = "Metric"
    )

# save the png
ggsave(
    filename = "plots/sa_combined_aemo_opennem_plot.png", 
    plot = sa_combined_aemo_opennem_plot,
    height = 210,
    width = 297,
    units = "mm"
)

# quick look at wind vs temperature
sa_combined_aemo_opennem_tbl %>%
    filter(
        wind_g_wh > 0 & temperature_mean_c > 0
    ) %>%
    ggplot(aes(wind_g_wh, temperature_mean_c)) +
    geom_point(aes(colour=co2e_intensity_index))


sa_combined_aemo_opennem_tbl %>% View()

# model ------

# correlation
library(corrr)

# remove the settlement date and correlate 
sa_combined_aemo_opennem_cor <- sa_combined_aemo_opennem_tbl %>%
    select(-settlementdate) %>%
    correlate() 

# get the correlated metrics for the co2e intensity index
cdeii_corr_tbl <- sa_combined_aemo_opennem_cor %>%
    filter(term=="co2e_intensity_index") %>%
    pivot_longer(!term, names_to = "metric", values_to = "value") %>%
    select(-term) %>%
    drop_na() %>%
    arrange(value)

# plot it 
cdeii_corr_plot <- cdeii_corr_tbl %>%
    mutate(
        corr_type = if_else(condition = value > 0, "Positive", "Negative")
    ) %>%
    
    mutate(
        metric = str_replace(metric, "g_wh", "gwh")
    ) %>%
    ggplot(aes(fct_reorder(metric, value), value)) +
    geom_col(aes(fill=corr_type)) +
    coord_flip() +
    theme_tq() + 
    scale_fill_tq() +
    labs(
        title = "Correlation Plot for SA CO2e Intensity Index vs Various Generator Metrics",
        subtitle = "Data derived from AEMO and Open NEM, 29 May 2020 to 22 May 2021",
        caption = "9 June 2021, @morebento",
        y = "Correlation (Pearson Method)",
        x = "",
        fill = "Correlation"
    )

cdeii_corr_plot

# save the png
ggsave(
    filename = "plots/sa_cdeii_corr_plot.png", 
    plot = cdeii_corr_plot,
    height = 297,
    width = 210,
    units = "mm"
)
