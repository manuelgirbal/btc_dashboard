library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)

## Getting price data from [Blockchain.info](https://blockchain.info/)

# Define the API endpoint URL
url <- "https://api.blockchain.info/charts/market-price?timespan=15years&start=2010-08-01&format=json&sampled=false"

# Send the HTTP request to the API endpoint
response <- GET(url)

# Convert the response to a JSON object
json_data <- fromJSON(content(response, "text"))

# Extract the price data from the JSON object
prices <- json_data$values

# Change variables formats and names
btcprice <- as_tibble(
  prices |>
    transmute(
      date = as_date(format(as.POSIXct(x, origin = "1970-01-01"), "%Y-%m-%d")),
      price = round(y,2))
)

#Computing yearly variation (of avg price per year):
yearly_price <- btcprice |> 
  mutate(year = year(date))  |> 
  group_by(year) |> 
  summarise(avg_price = round(mean(price, na.rm = T),2)) |> 
  arrange(year) |> 
  mutate(year_var = if_else(is.na(avg_price/lag(avg_price)-1),
                            true = 0,
                            false = round((avg_price/lag(avg_price)-1),2)))