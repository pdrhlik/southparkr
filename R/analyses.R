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
			text = preprocess_text(text)
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
