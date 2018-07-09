#' Fetch episode list for a season data_frame.
#'
#' @param season_link
#' @param season_name
#' @param season_number
#' @param season_year
#'
#' @return data_frame
#' @export
fetch_season_episode_list <- function(season_link, season_name, season_number, season_year) {
	base_url <- "http://southpark.wikia.com"

	episode_nodes <- season_link %>%
		xml2::read_html() %>%
		rvest::html_nodes(".wikia-gallery-item .lightbox-caption a")

	episode_links <- episode_nodes %>%
		rvest::html_attr(name = "href")
	episode_links <- paste0(base_url, episode_links)

	episode_names <- episode_nodes %>%
		rvest::html_text()

	dplyr::data_frame(
		season_name = season_name,
		season_number = season_number,
		season_year = season_year,
		season_episode_number = seq_along(episode_links),
		season_link = season_link,
		episode_link = episode_links,
		episode_name = episode_names
	)
}

#' Fetch episode list.
#'
#' @export
fetch_episode_list <- function() {
	base_url <- "http://southpark.wikia.com"
	scipts_url <- paste0(base_url, "/wiki/Portal:Scripts")
	all_episode_links <- dplyr::data_frame()

	season_nodes <- scipts_url %>%
		xml2::read_html() %>%
		rvest::html_nodes(".wikia-gallery-item .lightbox-caption a")

	season_links <- season_nodes %>%
		rvest::html_attr(name = "href")
	season_links <- paste0(base_url, season_links)

	season_names <- season_nodes %>%
		rvest::html_text()

	seasons <- dplyr::data_frame(
		season_name = season_names,
		season_number = seq_along(season_names),
		season_link = season_links,
		season_year = seq(1997, 1997 + length(season_names) - 1)
	)

	all_episode_links <- purrr::pmap_df(as.list(seasons), fetch_season_episode_list)

	return(all_episode_links)
}

#' Fetch transcript for a single episode.
#'
#' @param episode_link
#'
#' @export
fetch_episode <- function(episode_link) {
	episode <- episode_link %>%
		xml2::read_html() %>%
		rvest::html_nodes("table:nth-of-type(1)") %>%
		rvest::html_table(fill = TRUE) %>%
		`[[`(2)

	return(episode)
}

#' Fetch transcripts for all episodes.
#'
#' @param episode_list
#'
#' @export
fetch_all_episodes <- function(episode_list) {
	episodes <- list()

	for (i_episode in 1:nrow(episode_list)) {
		fetched_episode <- fetch_episode(episode_list$episode_link[i_episode])

		episodes[[i_episode]] <- dplyr::data_frame(
			season = episode_list$season_name[i_episode],
			season_number = episode_list$season_number[i_episode],
			season_episode_number = episode_list$season_episode_number[i_episode],
			episode = episode_list$episode_name[i_episode],
			episode_number = i_episode,
			character = fetched_episode$X1,
			text = fetched_episode$X2,
			year = episode_list$season_year[i_episode]
		)
	}

	episodes <- dplyr::bind_rows(episodes)

	episodes <- dplyr::mutate(
			episodes,
			season = factor(season),
			episode = factor(episode)
		) %>%
		dplyr::filter(nchar(text) > 0)

	return(episodes)
}

#' Preprocess character names.
#'
#' @param characters
preprocess_characters <- function(characters) {
	result <- characters %>%
		stringr::str_replace_all("[:\"]", "") %>%
		stringr::str_to_lower()

	return(result)
}

#' Preprocess text to keep only alphanum character, spaces and apostrophes.
#'
#' @param text
preprocess_text <- function(text) {
	result <- text %>%
		# Erase all text parts in [] brackets
		stringr::str_replace_all("\\[.+?\\]", " ") %>%

		# Keep only alphanumeric character, whitespace and apostrophes
		stringr::str_replace_all("[^\\w\\d\\s']", " ") %>%

		# Replace multiple whitespace by one whitespace
		stringr::str_replace_all("\\s+", " ") %>%

		# Trim whitespace from both sides
		stringr::str_trim() %>%

		# Everything to lower case
		stringr::str_to_lower()

	return(result)
}
