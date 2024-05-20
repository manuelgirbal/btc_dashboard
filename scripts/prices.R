library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)

## Getting price data from [mempool.space](https://mempool.space/)

# Define the API endpoint URL
url <- "https://mempool.space/api/v1/historical-price?currency=USD"

# Send the HTTP request to the API endpoint
response <- GET(url)

# Convert the response to a JSON object
json_data <- fromJSON(content(response, "text"))

# Extract the price data from the JSON object
prices <- json_data$prices

# Change variables formats and names
btcprice <- as_tibble(
  prices |>
    transmute(
      date = as_date(format(as.POSIXct(time, origin = "1970-01-01"), "%Y-%m-%d")),
      price = round(USD,2))
)

# Compute mean daily price
btcprice <- btcprice |> 
  group_by(date) |> 
  summarise(price = mean(price))

#Computing yearly variation (of avg price per year):
yearly <- btcprice %>%
  mutate(year = year(date)) %>%
  group_by(year) %>%
  summarise(avg_price = round(mean(price, na.rm = T),2)) %>%
  arrange(year) %>%
  mutate(year_var = round((avg_price/lag(avg_price)-1),2)) %>%
  replace(is.na(.), 0)
