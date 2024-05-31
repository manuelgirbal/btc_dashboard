library(tidyverse)
library(httr)
library(jsonlite)

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


library(countrycode)
library(rnaturalearth)
library(rnaturalearthdata)

# Get country name
country_name <- countrycode(sourcevar = nodes_df$country_code,
                            origin = 'ecb',
                            destination = 'country.name')

nodes_df <- cbind(nodes_df, country_name)

# Creating a nodes count and joining with world dataframe
node_counts <- nodes_df |> 
  filter(!is.na(country_name)) |> 
  group_by(country_name, country_code) |> 
  summarise(nodes = n())


# Adding polygon data to dataset

world_nodes <- ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(admin != "Antarctica") %>%
  mutate(country_code = iso_a2) %>%
  left_join(node_counts, by = "country_code")



# Creating and plotting map

nodes_map <- world_nodes %>%
  ggplot() +
  geom_sf(aes(fill = nodes)) +
  labs(title = "Bitcoin's currently running nodes by country",
       caption = "Source: https://bitnodes.io/") +
  scale_fill_gradient2(low = "white", mid = "lightgrey", high = "darkorange", na.value = "white") +
  theme(plot.background = element_rect(fill = "#A6A6A6"),
        panel.background = element_rect(fill = "#A6A6A6"),
        panel.grid.major = element_line(colour = "#7A7A7A")
  )


library(leaflet)

leaflet() |> 
  setView(lng = nodes_df$longitude, lat = nodes_df$latitude, zoom = 6) |> 
  addProviderTiles("Esri.WorldStreetMap") |> 
  addCircles(
    data = nodes_df,
    radius = nodes_df$node_id
  )


leaflet(nodes_df) |> 
  addTiles() |> 
  addCircleMarkers(lng = ~longitude, lat = ~latitude, 
                   popup = ~nodes_df$node_id)
