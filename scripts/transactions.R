library(shroomDK)
library(dplyr)
library(ggplot2)
library(lubridate)

# https://docs.flipsidecrypto.com/flipside-api/getting-started

api_key = readLines("api_keys.txt") # always gitignore your API keys!

query <- {
  "
  select date(date_trunc('Month', block_timestamp)) as month,
       count(*) as txs
  from bitcoin.core.fact_transactions
  group by 1
  order by 1 desc
  "
}

pull_data <- auto_paginate_query(
  query = query,
  api_key = api_key
)


# Constructing the table:
df_txs <- as_tibble(
  pull_data |> 
    transmute(date = as_date((ymd_hms(month))),
              txs)
)

#Computing yearly variation of transactions:
yearly_txs <- df_txs |> 
  mutate(year = year(date))  |> 
  group_by(year) |> 
  summarise(y_txs = sum(txs)) |> 
  arrange(year) |> 
  mutate(year_var = if_else(is.na(y_txs/lag(y_txs)-1),
                            true = 0,
                            false = round((y_txs/lag(y_txs)-1),2)))
