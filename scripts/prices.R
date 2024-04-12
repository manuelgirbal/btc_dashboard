library(shroomDK)
library(dplyr)
library(ggplot2)
library(lubridate)

# https://docs.flipsidecrypto.com/flipside-api/getting-started

api_key <- readLines("api_keys.txt") # always gitignore your API keys!

query <- {
  "
  select date(date_trunc('Day', hour)) as day,
         avg(close) as price
  from bitcoin.price.fact_hourly_token_prices
  group by 1
  order by 1 desc
  "
}

pull_data <- auto_paginate_query(
  query = query,
  api_key = api_key
)


# Constructing the table:
df_prices <- as_tibble(
  pull_data %>%
    transmute(day = as_date(ymd_hms(day)),
              price = round(price, 1))
)


# Creating plot:
btcprice_plot <- df_prices %>%
  ggplot(aes(day, price)) +
  geom_line() +
  ylab("USD Price") +
  xlab("Date") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme(plot.background = element_rect(fill = "#A6A6A6"),
        panel.background = element_rect(fill = "#A6A6A6"),
        panel.grid.major = element_line(colour = "#7A7A7A"))