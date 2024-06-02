source("scripts/prices.R")
source("scripts/transactions.R")
source("scripts/nodes.R")

save(btcprice, df_txs, yearly_price, yearly_txs, nodes_df, nodes_map,
     file = "test/test.RData")
