library(tidyverse)
library(httr)
library(jsonlite)
library(lubridate)

## Getting price data from [Blockchain.info](https://blockchain.info/)

# Define the API endpoint URL
url <- "https://api.blockchain.info/charts/n-transactions?timespan=15years&format=json&sampled=false"

# Send the HTTP request to the API endpoint
response <- GET(url)

# Convert the response to a JSON object
json_data <- fromJSON(content(response, "text"))

# Extract the txs data from the JSON object
df_txs <- as_tibble(json_data$values)

# Change variables formats and names
df_txs <- df_txs |>
  transmute(
    date = as_date(format(as.POSIXct(x, origin = "1970-01-01"), "%Y-%m-%d")),
    txs = y)

#Computing yearly variation of transactions:
yearly_txs <- df_txs |> 
  mutate(year = year(date))  |> 
  group_by(year) |> 
  summarise(y_txs = sum(txs)) |> 
  arrange(year) |> 
  mutate(year_var = if_else(is.na(y_txs/lag(y_txs)-1),
                            true = 0,
                            false = round((y_txs/lag(y_txs)-1),2)))

