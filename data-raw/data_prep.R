# This script downloads and parses episode lists,
# episode lines and imdb ratings for episodes.

episode_list <- southparkr::fetch_episode_list()
episode_lines <- southparkr::fetch_all_episodes(episode_list)
imdb_ratings <- southparkr::fetch_ratings(
	force_download = TRUE,
	make_rds = FALSE,
	delete_files = TRUE
)

devtools::use_data(episode_list, overwrite = TRUE)
devtools::use_data(episode_lines, overwrite = TRUE)
devtools::use_data(imdb_ratings, overwrite = TRUE)
