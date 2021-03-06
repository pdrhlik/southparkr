#' Plot comparison of swear words proportion among selected characters.
#'
#' It uses the \code{\link{compare_two_characters}} function but
#'   compares more than two characters at once. After that, it
#'   draws an errorbar plot to visually compare the results.
#'
#' @param main_character South Park character to compare with others.
#' @param other_characters Character vector of other characters.
#' @param words A data frame of words from \code{\link{process_episode_words}}.
#' @param text_size Numeric value that controls ggplot's text size.
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
#' @param words A data frame of words from \code{\link{process_episode_words}}.
#' @param characters Character vector of characters.
#'
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
