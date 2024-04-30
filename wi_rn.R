library(sf)
library(PlotTools)
library(dplyr)
library(SUNGEO)

#sf_use_s2(FALSE)

###############################################################################
# This script analyzes proposals for redistricting in the State of Wisconsin  #
# submitted after the 2020 census.  Proposals for redistricting,  including   #
# for the Wisconsin State Assembly (wsa), Wisconsin State Senate (wss), and   #
# U.S. Congress (wc) are analyzed against community of interest (coi) proxies.#
# Final outputs include spatial relative nesting (RN) scores for each         #
# combination of redistricting proposal and coi, using both cois and          #
# redistricting proposals as the source, and population RN scores using       #
# both cois and redistricting proposals as the source.  Spatial RN scores are #
# calculated using the SUNGEO package and population RN scores are calculated #
# manually using the formula pioneered by Zhukov, Byers, Davidson and Kollman #
# in "Integrating Data Across Misaligned Spatial Units (2022)".               #
###############################################################################

############ Load Required Maps ############
#COI Maps
dmas <- sf::read_sf(dsn =  "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/dmas.geojson")
#school_dist <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/unified_school_dist_buffered.geojson")
combined_sa <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/combined_sa.geojson")
met_mic_sa <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/met_mic_sa.geojson")
met_sa <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/met_sa.geojson")
mic_sa <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/mic_sa.geojson")

coi_list <- list(dmas, 
#                 school_dist, 
                 combined_sa, 
                 met_mic_sa, 
                 met_sa, 
                 mic_sa)

coi_list_names <- list("Media Districts", 
#                       "School Districts", 
                       "Combined Statistical Areas", 
                       "Metro- and Micro- Statistical Areas Combined", 
                       "Metropolitan Statistical Areas", 
                       "Micropolitan Statistical Areas")

#2022 Maps
wsa_2022 <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/wsa_2022.geojson")
wss_2022 <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/wss_2022.geojson")
wc_2022 <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/wc_2022.geojson")

#2024 Maps
wsa_2024 <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/wsa_2024.geojson")
wss_2024 <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/wss_2024.geojson")

#academic models
fox_fair <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/fox_fair.geojson")
petering_wsa <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/petering_wsa.geojson")
petering_wss <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/petering_wss.geojson")

#other
#evers commission
evers <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/evers.geojson")
#ryan maps
ryan <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/ryan.geojson")

maps_list <- list(wsa_2022, 
                  wss_2022, 
                  wc_2022,
                  wsa_2024, 
                  wss_2024, 
                  fox_fair, 
                  petering_wsa,
                  petering_wss,
                  evers, 
                  ryan)

maps_list_names <- list("2022 Assembly", 
                        "2022 Senate",
                        "2022 Congressional", 
                        "2024 Assembly", 
                        "2024 Senate", 
                        "Fox Fair",
                        "Petering Assembly", 
                        "Petering Senate", 
                        "Evers Commission", 
                        "Ryan's")

#census blocks
census_blocks <- sf::read_sf(dsn = "/Users/lukeschields/Documents/Documents (icloud)/Y2 S2/API 231/Final Project/test/census_blocks.geojson")


############ Geospatial Relative Nesting Scores ############
#Using COI polygons as source data

#Cretate Matrix to hold RN scores
rn_matrix_coi_source <- matrix(data = NA, nrow = length(coi_list), ncol = length(maps_list))
rownames(rn_matrix_coi_source) <- coi_list_names
colnames(rn_matrix_coi_source) <- maps_list_names

for(i in 1:length(coi_list)) {
  for(j in 1:length(maps_list)) {
    nest <- SUNGEO::nesting(
      poly_from = coi_list[[i]],
      poly_to = maps_list[[j]]
    )
    rn_matrix_coi_source[i,j] <- round(nest$rn, 4)
  }
}

rn_matrix_coi_source <- as.data.frame(rn_matrix_coi_source)


#Using District maps as source data

#Create Matrix for RN scores
rn_matrix_maps_source <- matrix(data = NA, nrow = length(coi_list), ncol = length(maps_list))
rownames(rn_matrix_maps_source) <- coi_list_names
colnames(rn_matrix_maps_source) <- maps_list_names

for(i in 1:length(coi_list)) {
  for(j in 1:length(maps_list)) {
    nest <- SUNGEO::nesting(
      poly_from = maps_list[[j]],
      poly_to = coi_list[[i]]
    )
    rn_matrix_maps_source[i,j] <- round(nest$rn, 4)
  }
}
rn_matrix_maps_source <- as.data.frame(rn_matrix_maps_source)

############ Determining "ainj" Scores Using Population ############

#create empty matrices
#matrix for summed ainj scores using coi map as source
poprn_matrix_coi_source <- matrix(NA, length(coi_list), length(maps_list))
rownames(poprn_matrix_coi_source) <- coi_list_names
colnames(poprn_matrix_coi_source) <- maps_list_names

#matrix for summed ainj scores using district map as source
poprn_matrix_maps_source <- matrix(NA, length(coi_list), length(maps_list))
rownames(poprn_matrix_maps_source) <- coi_list_names
colnames(poprn_matrix_maps_source) <- maps_list_names

for(coi in seq_along(coi_list)) {
  for(map in seq_along(maps_list)) {
    intersect <- st_intersection(coi_list[[coi]], maps_list[[map]])
    intersect$index <- seq(1:nrow(intersect))
    intersect2 <- st_intersection(intersect, census_blocks)
    intersect2$intersect_area <- st_area(intersect2)
    intersect2$cb_weight <- (intersect2$intersect_area / intersect2$area)
    intersect2_pop <- intersect2 %>%
      group_by(cb_index) %>%
      slice(which.max(cb_weight)) %>%
      ungroup() %>%
      group_by(index) %>%
      summarize(intersect_pop = sum(cb_pop)) %>%
      as.data.frame()
    intersect <- left_join(intersect, intersect2_pop, by = "index")
    intersect$coi_ainj <- ((intersect$intersect_pop/intersect$coi_pop)^2)
    intersect$map_ainj <- ((intersect$intersect_pop/intersect$map_pop)^2)
    
    poprn_matrix_coi_source[coi, map] <- sum(intersect$coi_ainj, na.rm = TRUE)
    poprn_matrix_maps_source[coi,map] <- sum(intersect$map_ainj, na.rm = TRUE)
  }
}

############ Factors ############
#COI
#DMA
dma_factor <- 1/nrow(dmas)

#Combined SAs
combined_sa_factor <- 1/nrow(combined_sa)

#Met Mic combined SAs
met_mic_sa_factor <- 1/nrow(met_mic_sa)

#Met SAs
met_sa_factor <- 1/nrow(met_sa)

#Mic SAs
mic_sa_factor <- 1/nrow(mic_sa)

coi_factors <- list(dma_factor,
                    combined_sa_factor,
                    met_mic_sa_factor,
                    met_sa_factor,
                    mic_sa_factor)

#Maps
#wsa_2022
wsa_2022_factor <- 1/nrow(wsa_2022)

#wss_2022
wss_2022_factor <- 1/nrow(wss_2022)

#wc_factor
wc_factor <- 1/nrow(wc_2022)

#wsa_2024
wsa_2024_factor <- 1/nrow(wsa_2024)

#wss_2024
wss_2024_factor <- 1/nrow(wss_2024)

#fox fair
fox_fair_factor <- 1/nrow(fox_fair)

#petering wsa
petering_wsa_factor <- 1/nrow(petering_wsa)

#petering wss
petering_wss_factor <- 1/nrow(petering_wss)

#evers
evers_factor <- 1/nrow(evers)

#ryan
ryan_factor <- 1/nrow(ryan)

maps_factors <- list(wsa_2022_factor,
                     wss_2022_factor,
                     wc_factor,
                     wsa_2024_factor,
                     wss_2024_factor,
                     fox_fair_factor,
                     petering_wsa_factor,
                     petering_wss_factor,
                     evers_factor,
                     ryan_factor)


############ Population Relative Nesting Score Calculations ############
#coi source matrix
for(i in 1:ncol(poprn_matrix_coi_source)) {
  for(j in 1:nrow(poprn_matrix_coi_source)) {
    poprn_matrix_coi_source[j,i] <- (poprn_matrix_coi_source[j,i] * coi_factors[[j]])
  }
}

poprn_matrix_coi_source <- as.data.frame(poprn_matrix_coi_source)

#maps source matrix
for(i in 1:ncol(poprn_matrix_maps_source)) {
  for(j in 1:nrow(poprn_matrix_maps_source)) {
    poprn_matrix_maps_source[j,i] <- (poprn_matrix_maps_source[j,i] * maps_factors[[i]])
  }
}

poprn_matrix_maps_source <- as.data.frame(poprn_matrix_maps_source)

############ Display Nesting Score Matrices ############
rn_matrix_coi_source

rn_matrix_maps_source

poprn_matrix_coi_source

poprn_matrix_maps_source
