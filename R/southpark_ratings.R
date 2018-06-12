fetch_ratings <- function() {
	# South Park episode list with user ratings
	rating_url <- "http://www.imdb.com/title/tt0121955/eprate"

	ratings_table <- rating_url %>%
		read_html() %>%
		html_nodes("#tn15content table") %>%
		`[[`(1) %>%
		html_table() %>%
		# Only keep columns that have names
		select(matches("."))

	colnames(ratings_table) <- c("season_episode", "episode_name", "user_rating", "user_votes")

	ratings <- ratings_table %>%
		mutate(
			user_votes = as.integer(sub(",", "", user_votes)),
			season_number = as.integer(str_extract(season_episode, "^\\d+")),
			episode_number = as.integer(str_extract(str_trim(season_episode), "\\d+$"))
		) %>%
		select(-season_episode)

	return(ratings)
}
