## code to prepare continents and biome geojson files loaded in internal
# functions `continents` and `biomes`, respectively.

if (!dir.exists("inst/biomes")) {
  dir.create("inst/biomes", recursive = TRUE)
}
if (!dir.exists("inst/continents")) {
  dir.create("inst/continents", recursive = TRUE)
}
sf::sf_use_s2(FALSE)

continents <- rnaturalearth::ne_countries(returnclass = "sf") |>
  dplyr::group_by(continent) |>
  dplyr::summarise() |>
  sf::st_make_valid()

sf::write_sf(continents, "inst/continents/ne_continents.fgb",
  delete_dsn = TRUE
)

# sf::read_sf("inst/continents/ne_continents.fgb") |>
#   mapview::mapview()

if (!file.exists("data-raw/eco_regions.gpkg")) {
  eco_regions <- sf::read_sf(paste0(
    "/vsizip/vsicurl/",
    "https://storage.googleapis.com/teow2016/Ecoregions2017.zip/",
    "Ecoregions2017.shp"
  )) |>
    sf::st_make_valid()

  sf::write_sf(eco_regions, "data-raw/eco_regions.gpkg")
} else {
  eco_regions <- sf::read_sf("data-raw/eco_regions.gpkg")
}

er_simple <- eco_regions |>
  dplyr::select(BIOME_NAME) |>
  rmapshaper::ms_simplify(keep = 0.001, sys = TRUE) |>
  sf::st_make_valid() |>
  dplyr::filter(BIOME_NAME != "N/A") |>
  sf::st_make_valid()


biomes <- er_simple |>
  dplyr::group_by(BIOME_NAME) |>
  dplyr::summarise() |>
  wk::wk_flatten() |>
  sf::st_make_valid()


sf::write_sf(biomes, "inst/biomes/eco_biomes.fgb", delete_dsn = TRUE)
# sf::read_sf("inst/biomes/eco_biomes.fgb") |>
#   mapview::mapview()
if (file.exists("data-raw/eco_regions.gpkg")) {
  file.remove("data-raw/eco_regions.gpkg")
}
