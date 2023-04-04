# Load libraries
library(dplyr) # data wrangling
library(tidyr)
library(readr)
library(stringr)
library(geojsonsf)
library(sf) # simple features - geospatial geometries
library(osmdata) # obtaining OpenStreetMap vector data

# function for reading in zipped spatial files with single layer
read_URL <- function(URL, layer, query){
  cur_tempfile <- tempfile()
  download.file(url = URL, destfile = cur_tempfile)
  out_directory <- tempdir(check = TRUE)
  unzip(cur_tempfile, exdir = out_directory)

  st_read(dsn = out_directory, layer = layer)
}

# Load soundscapes by type
calm_sites <- st_read(dsn = "./raw_data/Calm & tranquil [Characteristic soundscapes].kml")
boring_sites <- st_read(dsn = "./raw_data/Boring & lifeless [Characteristic soundscapes].kml")
exciting_sites <- st_read(dsn = "./raw_data/Full of life & exciting [Characteristic soundscapes].kml")
chaotic_sites <- st_read(dsn = "./raw_data/Chaotic & restless [Characteristic soundscapes].kml")

# Convert to geojson for web map
st_write(calm_sites, "./src/data/transformed/calm_sites.geojson")
st_write(boring_sites, "./src/data/transformed/boring_sites.geojson")
st_write(exciting_sites, "./src/data/transformed/exciting_sites.geojson")
st_write(chaotic_sites, "./src/data/transformed/chaotic_sites.geojson")

# Load planning area boundary
zones <- st_read(dsn = "./raw_data/planning-boundary-area.kml") %>% mutate(planning_area = str_to_title(PLN_AREA_N))

# Load Kontur population density data
pop_density <- geojson_sf("./src/data/transformed/pop_density.geojson")
# # Load nature-related features
# parks <- st_read(dsn = "./raw_data/nparks-parks-and-nature-reserves-kml.kml") %>% st_make_valid()
# waters <- st_read(dsn = "./raw_data/abc-water-sites.kml") %>% st_make_valid()

#Get average population density (count per hexagon grid) for each soundscape type
get_density <- function(site, pop_density){
  st_join(site, pop_density, join = st_intersects) %>% summarise(mean = mean(population, na.rm = TRUE))
}

for (i in list(calm_sites, boring_sites, exciting_sites, chaotic_sites)){
  print(get_density(i,pop_density)$mean)
}

## Obtain Singapore polygon and green features
city_polygon <- getbb("Singapore",
                      featuretype = "Administrative",
                      format_out = "polygon")

query1 <-
  opq(bbox = city_polygon) %>%  
# To extract  features that are park or nature reserve
  add_osm_feature(key = "leisure",
                  value = c("park", "nature_reserve"))

query2 <-
  opq(bbox = city_polygon) %>%  
  # To extract  features that are park or nature reserve
  add_osm_feature(key = "landuse",
                  value = c("forest"))

query3 <-
  opq(bbox = city_polygon) %>%  
  # To extract  features that are park or nature reserve
  add_osm_feature(key = "natural",
                  value = c("water"))

greensp_osm <- c(osmdata_sf (query1), osmdata_sf (query2), osmdata_sf(query3)) %>% 
# query OSM and return as simple features (sf)
trim_osmdata(city_polygon)

greensp_sf <- bind_rows(st_cast(greensp_osm$osm_polygons, "MULTIPOLYGON"),
                        greensp_osm$osm_multipolygons) %>%
  mutate(feature_type = coalesce(leisure,landuse, natural)) %>%
  select(name, osm_id, feature_type) %>% 
  filter(feature_type %in% c("park", "nature_reserve", "forest", "water", "quarry", "reservoir", "wetland") )  %>% 
  st_make_valid()

plot(greensp_sf["feature_type"])

# Get proportion of soundscapes that intersect with green spaces by type
for (i in list(calm_sites, boring_sites, exciting_sites, chaotic_sites)){
  # Green spaces from OSM contain overlapping polygons. Use distinct operation to retain only first intersection for each site that results from the left join (to keep total soundscape count the same).
  intersect <- st_join(i,greensp_sf, st_intersects) %>% distinct(Name,.keep_all = TRUE)
  print(sum(!is.na(intersect$feature_type))/nrow(intersect))
}

st_write(greensp_sf, "./src/data/transformed/greenspaces.geojson")

## Get median income bracket for each planning area
income <- read_csv("./raw_data/extracted - resident_income.csv") %>% pivot_longer(!planning_area, names_to = "income_range", values_to = "resident_count")
median_income <- income %>% group_by(planning_area) %>% mutate(total_resident = cumsum(resident_count)) %>% 
  group_by(planning_area) %>% mutate(median = ceiling(dplyr::last(total_resident)/2)) %>% 
# Select only columns with the planning area, median income bracket, and total resident count for area
  filter( total_resident >= median) %>% distinct(planning_area, .keep_all = TRUE) %>% select(planning_area, income_range, total_resident)
# Combine income data with planning area spatial data
zones_income <- merge(zones, median_income)
# Get count of calm and tranquil sites by planning area
zones_income$site_count <- lengths(st_intersects(zones_income, calm_sites))
st_write(zones_income, "./src/data/transformed/zones_income.geojson")