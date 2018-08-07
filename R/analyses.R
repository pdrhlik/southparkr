#' List of words that are considered naughty.
#'
#' This function will be replaced in the future
#'   by the \href{https://github.com/pdrhlik/sweary}{sweary}
#'   package.
#'
#' @return Character vector of swear words.
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
#' Each row of the data frame is a word spoken by a character in an episode.
#'   Appart from data from \code{\link{episode_lines}} and \code{\link{imdb_ratings}},
#'   it also contains a sentiment score, a word stem and a logical flag saying
#'   if a word is a **swear** word or not.
#'
#' @param lines \code{\link{episode_lines}}
#' @param ratings \code{\link{imdb_ratings}}
#' @param keep_stopwords If \code{TRUE}, (default \code{FALSE}), the dataset
#'   will contain stopwords after processing.
#'
#' @return A data frame of words.
#' @export
process_episode_words <- function(lines, ratings, keep_stopwords = FALSE) {
	episode_words <- lines %>%
		dplyr::mutate(
			character = preprocess_characters(character),
			text = preprocess_text(text)
		) %>%
		tidytext::unnest_tokens(word, text) %>%
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
		dplyr::left_join(tidytext::get_sentiments("afinn")) %>%
		rename(sentiment_score = score)

	if (keep_stopwords == FALSE) {
		episode_words <- dplyr::anti_join(episode_words, tidytext::stop_words, by = "word")
	}

	return(episode_words)
}

#' Compare two characters and decide which one is naughtier.
#'
#' It uses a proportion test (\code{\link[stats]{prop.test}}) to
#'   determine if one character is naughtier than the other.
#'
#' @param char2 Character name.
#' @param char1 Character name.
#' @param words A data frame of words returned by
#'   \code{\link{process_episode_words}}.
#'
#' @return A data frame of prop.test results.
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
#' @param words A data frame of words returned by
#'   \code{\link{process_episode_words}}.
#' @param n Numeric value - how many TOP talking
#'   characters to select.
#'
#' @return Character vector of character names.
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
