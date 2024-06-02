library(tidyverse)
library(httr)
library(jsonlite)
library(leaflet)

## Getting nodes data from [Bitnodes](https://bitnodes.io/)

# Define the API endpoint URL
url <- "https://bitnodes.io/api/v1/snapshots/latest/"

# Send the HTTP request to the API endpoint
response <- GET(url)

# Convert the response to a JSON object
json_data <- fromJSON(content(response, "text"))

# Extract the nodes data from the JSON object
nodes <- json_data$nodes

node_ids <- names(nodes)

nodes_df <- as_tibble(data.frame(node_ids, do.call(rbind, nodes), stringsAsFactors = FALSE))

colnames(nodes_df) <- c("node_id", "protocol", "user_agent", "connected_since", "services", "height", "hostname", "city", "country_code", "latitude", "longitude", "timezone", "asn", "organization_name")

nodes_df$latitude <- as.numeric(nodes_df$latitude)
nodes_df$longitude <- as.numeric(nodes_df$longitude)


# Creating the map plot

nodes_map <- leaflet(nodes_df) |>
  addTiles() |>
  addCircleMarkers(lng = ~longitude,
                   lat = ~latitude,
                   popup = ~city,
                   color = "darkorange",
                   fillColor = "orange",
                   radius = 1) |> 
  setView(lng = 0, lat = 15, zoom = 2)


# Save used objects while hosting in shinyapps.io
save(nodes_df, nodes_map,
     file = "data/nodes.RData")
