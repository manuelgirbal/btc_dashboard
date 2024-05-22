source("scripts/prices.R")
source("scripts/transactions.R")

save(btcprice, df_txs, yearly_price, yearly_txs,
     file = "test.RData")
