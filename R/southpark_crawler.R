library(tidyverse)
library(tidytext)
library(rvest)
library(stringr)
library(SnowballC)
library(broom)

#' Fetch episode list.
fetch_episode_list <- function() {
	base_url <- "http://southpark.wikia.com"
	scipts_url <- paste0(base_url, "/wiki/Portal:Scripts")
	all_episode_links <- data_frame()

	season_nodes <- scipts_url %>%
		read_html() %>%
		html_nodes(".wikia-gallery-item .lightbox-caption a")

	season_links <- season_nodes %>%
		html_attr(name = "href")
	season_links <- paste0(base_url, season_links)

	season_names <- season_nodes %>%
		html_text()

	seasons <- data_frame(
		season_name = season_names,
		season_link = season_links,
		season_year = seq(1997, 1997 + length(season_names) - 1)
	)

	for (i_season in 1:nrow(seasons)) {
		episode_nodes <- seasons$season_link[i_season] %>%
			read_html() %>%
			html_nodes(".wikia-gallery-item .lightbox-caption a")

		episode_links <- episode_nodes %>%
			html_attr(name = "href")
		episode_links <- paste0(base_url, episode_links)

		episode_names <- episode_nodes %>%
			html_text()

		all_episode_links <- rbind(all_episode_links, data_frame(
			season_name = seasons$season_name[i_season],
			season_number = i_season,
			season_year = seasons$season_year[i_season],
			season_episode_number = seq_along(episode_links),
			season_link = seasons$season_link[i_season],
			episode_link = episode_links,
			episode_name = episode_names
		))
	}

	return(all_episode_links)
}

#' Fetch transcript for a single episode.
fetch_episode <- function(episode_link) {
	episode <- episode_link %>%
		read_html() %>%
		html_nodes("table:nth-of-type(1)") %>%
		html_table(fill = TRUE) %>%
		`[[`(2)

	return(episode)
}

#' Fetch transcript from all episodes.
fetch_all_episodes <- function(episode_list) {
	episodes <- list()

	for (i_episode in 1:nrow(episode_list)) {
		fetched_episode <- fetch_episode(episode_list$episode_link[i_episode])

		episodes[[i_episode]] <- data_frame(
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

	episodes <- bind_rows(episodes)

	episodes <- mutate(
			episodes,
			season = factor(season),
			episode = factor(episode)
		) %>%
		filter(nchar(text) > 0)

	return(episodes)
}

#' Fetch IMDB rating for each episode.
fetch_ratings <- function() {
	# South Park episode list with user ratings
	rating_url <- "http://www.imdb.com/title/tt0121955/eprate"

	# Fetch ratings table from imdb
	ratings_table <- rating_url %>%
		read_html() %>%
		html_nodes("#tn15content table") %>%
		# Only keep the first table which contains the ratings
		`[[`(1) %>%
		html_table() %>%
		# Only keep columns that have names
		select(matches("."))

	# Rename columns
	colnames(ratings_table) <- c("season_episode", "episode_name", "user_rating", "user_votes")

	ratings <- ratings_table %>%
		mutate(
			user_votes = as.integer(sub(",", "", user_votes)),
			season_number = as.integer(str_extract(season_episode, "^\\d+")),
			season_episode_number = as.integer(str_extract(str_trim(season_episode), "\\d+$"))
		) %>%
		select(-season_episode)

	return(ratings)
}

#' Preprocess character names.
preprocess_characters <- function(characters) {
	characters %>%
		str_replace_all("[:\"]", "") %>%
		str_to_lower()
}

#' Preprocess text to keep only alphanum character, spaces and apostrophes.
preprocess_text <- function(text) {
	text %>%
		# Erase all text parts in [] brackets
		str_replace_all("\\[.+?\\]", " ") %>%

		# Keep only alphanumeric character, whitespace and apostrophes
		str_replace_all("[^\\w\\d\\s']", " ") %>%

		# Replace multiple whitespace by one whitespace
		str_replace_all("\\s+", " ") %>%

		# Trim whitespace from both sides
		str_trim() %>%

		# Everything to lower case
		str_to_lower()
}

swear_words <- c("shit", "fuck", "motherfuck", "cunt", "ass", "asshole", "cum",
				 "gay", "dick", "dickhead", "piss", "douche", "douchebag", "twat",
				 "bitch", "damn", "crap", "balls", "tit", "pussy", "slut", "fag",
				 "fatass", "assholes", "gai", "shitti", "pussi", "damn", "goddamn",
				 "bullshit", "bullcrap", "dumbass")

episode_list <- fetch_episode_list()
episodes <- fetch_all_episodes(episode_list)
ratings <- fetch_ratings()

episodes_words <- episodes %>%
	mutate(
		character = preprocess_characters(character),
		text = preprocess_text(text)
	) %>%
	unnest_tokens(word, text) %>%
	anti_join(stop_words, by = "word") %>%
	filter(nchar(character) > 0) %>%
	mutate(
		word_stem = SnowballC::wordStem(word),
		swear_word = word_stem %in% swear_words | word %in% swear_words
	) #%>%
	# left_join(
	# 	ratings,
	# 	by = c("season_number" = "season_number",
	# 		   "season_episode_number" = "season_episode_number")
	# )
