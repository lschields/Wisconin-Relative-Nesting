# Wisconin-Relative-Nesting

This project was performed as a project for API 231: Geographic Information Systems for Public Policy at the Harvard Kennedy School by Luke Schields and Ryan Grunwald.

The script (wi_rn.r) analyzes proposals for redistricting in the State of Wisconsin submitted after the 2020 census.  Proposals for redistricting, including for the Wisconsin State Assembly (wsa), Wisconsin State Senate (wss), and U.S. Congress (wc) are analyzed against community of interest (coi) proxies. Final outputs include spatial relative nesting (RN) scores for each combination of redistricting proposal and coi, using both cois and redistricting proposals as the source, and population RN scores using both cois and redistricting proposals as the source. Spatial RN scores are calculated using the SUNGEO package and population RN scores are calculated manually using the formula pioneered by Zhukov, Byers, Davidson and Kollman in "Integrating Data Across Misaligned Spatial Units" (2022).

$RN = \frac{1}{N_s} \sum\limits_{i}^{N_s} \sum\limits_{i\cap j}^{N_{i\cap D}} \left( \frac{a_{i\cap j}}{a_i} \right)^2$ \n
Where $G_s$ is the set of source polygons, indexed $i$ = 1,... $N_s$,  
$G_D$ is the set of destination polygons, indexed $j$ = 1,... $N_D$,  
$G_{s\cap D}$ is the set of intersected polygons, indexed $i\cap j$ = 1  

COI maps analyzed include:
1. Designated Media Districts (dmas.geojson) from Nielson
2. Combined Statistical Areas (combined_sa.geojson) from the U.S. Census Bureau
3. Metropolitan Statistical Areas (met_sa.geojson) from the U.S. Census Bureau
4. Micropolitan Statistical Areas (mic_sa.geojson) from the U.S. Census Bureau
5. Metropolitan and Micropolitan Statistical Areas combined in the same map (met_mic_sa.geojson) from the U.S. Census Bureau
6. Wisconsin Unified School Districts from the Wisconsin Department of Public Instruction (school_dist.geojson)

Proposed redistricting maps analyzed include:
1. Petering Wisconsin State Senate proposal (petering_wss.geojson)
2. Petering Wisconsin State Assembly proposal (petering_wsa.geojson)
3. 2022 Wisconsin U.S. House Districts (wc_2022.geojson)
4. 2022 Wisconsin State Assembly Districts (wsa_2022.geojson)
5. 2022 Wisconsin State Senate Districts (wss_2022.geojson)
6. 2024 Wisconsin State Assembly Districts (wsa_2024.geojson)
7. 2024 Wisconsin State Senate Districts (wss_2024.geojson)
8. Governor Tony Evers U.S. House District proposal (evers.geojson)
9. Fox Fair U.S. House District proposal (fox_fair.geojson)
10. A hypothetical U.S. House District proposal designed by project team member Ryan Grunwald (ryan.geojson)

NOTE:
Our census block file was too large (750mb) to push to github. The 2023 TIGER/Line Shapefile can be downloaded from the U.S. Census Bureau's website [here]([url](https://www.census.gov/cgi-bin/geo/shapefiles/index.php?year=2023&layergroup=Blocks+%282020%29)) and ran through census_block_prep.r locally to prepare it for the analysis.
https://www.census.gov/cgi-bin/geo/shapefiles/index.php?year=2023&layergroup=Blocks+%282020%29 

Additionally, the school district file may be used for the geospatial relative nesting analysis only, and should be removed from 'coi_list' prior to performing the population relative nesting analysis.
