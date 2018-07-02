#' List of words that are considered naughty.
#'
#' @export
swear_words <- function() {
	return(c("shit", "fuck", "motherfuck", "cunt", "ass", "asshole", "cum",
			 "gay", "dick", "dickhead", "piss", "douche", "douchebag", "twat",
			 "bitch", "damn", "crap", "balls", "tit", "pussy", "slut", "fag",
			 "fatass", "assholes", "gai", "shitti", "pussi", "damn", "goddamn",
			 "bullshit", "bullcrap", "dumbass"))
}

#' Processes lines and ratings and creates a data frame usable for analyses.
#'
#' @param lines
#' @param ratings
#'
#' @return
#' @export
process_episode_words <- function(lines, ratings) {
	episode_words <- lines %>%
		dplyr::mutate(
			character = preprocess_characters(character),
			text = preprocess_text(text),
			line_number = row_number()
		) %>%
		tidytext::unnest_tokens(word, text) %>%
		dplyr::anti_join(tidytext::stop_words, by = "word") %>%
		dplyr::filter(nchar(character) > 0) %>%
		dplyr::mutate(
			word_stem = SnowballC::wordStem(word),
			swear_word = word_stem %in% swear_words() | word %in% swear_words()
		) %>%
		dplyr::left_join(
			ratings,
			by = c("season_number" = "season_number",
				   "season_episode_number" = "season_episode_number")
		) %>%
		dplyr::left_join(tidytext::get_sentiments("afinn"))

	return(episode_words)
}

#' Compare two characters and decide which one is naughtier.
#'
#' @param char2
#' @param char1
#' @param words
#'
#' @export
compare_two_characters <- function(char2, char1, words) {
	char_1 <- dplyr::filter(words, character == char1)
	char_2 <- dplyr::filter(words, character == char2)

	char_1_summary <- char_1 %>%
		dplyr::summarise(swear = sum(swear_word), total = n())
	char_2_summary <- char_2 %>%
		dplyr::summarise(swear = sum(swear_word), total = n())

	result <- prop.test(
		as.matrix(dplyr::bind_rows(char_1_summary, char_2_summary)),
		correct = FALSE
		) %>%
		broom::tidy() %>%
		dplyr::bind_cols(character = char2)

	return(result)
}

#' Select top N talking characters.
#'
#' @param words
#' @param n
#'
#' @export
top_n_characters <- function(words, n) {
	result <- words %>%
		dplyr::group_by(character) %>%
		dplyr::count(character) %>%
		dplyr::arrange(desc(n)) %>%
		dplyr::ungroup() %>%
		dplyr::top_n(n) %>%
		dplyr::select(character) %>%
		unlist(use.names = FALSE)

	return(result)
}

#' Plot comparison of naughty words proportion among selected characters.
#'
#' @param main_character
#' @param words
#' @param other_characters
#'
#' @export
plot_swear_word_comparison <- function(main_character, other_characters, words, text_size = 30) {
	result <- purrr::map_df(
		other_characters,
		compare_two_characters,
		main_character,
		words = words)

	ggplot2::ggplot(result, aes(x = reorder(character, -estimate2), estimate2)) +
		ggplot2::geom_errorbar(aes(ymin = conf.low, ymax = conf.high, col = p.value < 0.05), size = 2) +
		ggplot2::geom_hline(yintercept = 0, col = "red", linetype = "dashed", size = 2) +
		ggplot2::labs(
			x = "Characters",
			y = "prop.test estimate",
			title = "Cartman vs other characters (even himself)",
			subtitle = "Negative values mean that the character is naughtier than Cartman and vice versa"
		) +
		ggplot2::theme(
			text = ggplot2::element_text(size = text_size),
			axis.text.x = ggplot2::element_text(angle = 60, hjust = 1),
			legend.position = "none"
		)
}

#' Plots sentiment over episodes for selected characters.
#'
#' @param words
#' @param characters
#'
#' @return
#' @export
plot_character_sentiment <- function(words, characters) {
	by_character_episode <- words %>%
		dplyr::group_by(character, episode_number) %>%
		dplyr::summarise(
			air_date = air_date[1],
			score = mean(score, na.rm = TRUE)
		)

	dplyr::filter(by_character_episode, character %in% characters) %>%
		ggplot2::ggplot(., aes(episode_number, score, fill = character)) +
		ggplot2::geom_col() +
		ggplot2::geom_smooth() +
		ggplot2::labs(
			x = "Episode number",
			y = "Sentiment score"
		) +
		ggplot2::facet_wrap(~ character)
}
