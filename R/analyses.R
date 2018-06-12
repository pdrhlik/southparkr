by_season <- episodes_words %>%
	filter(nchar(character) > 0) %>%
	mutate(
		swear_word = word_stem %in% swear_words | word %in% swear_words
	) %>%
	group_by(season) %>%
	summarise(
		word_count = n(),
		mean_rating = mean(user_rating),
		median_rating = median(user_rating),
		swear_word_count = sum(swear_word),
		swear_word_ratio = sum(swear_word) / n()
	)

by_episode <- episodes_words %>%
	filter(nchar(character) > 0) %>%
	mutate(
		swear_word = word_stem %in% swear_words | word %in% swear_words
	) %>%
	group_by(episode) %>%
	summarise(
		season = season[1],
		season_number = season_number[1],
		season_episode_number = season_episode_number[1],
		episode_number = episode_number[1],
		word_count = n(),
		character_count = n_distinct(character),
		mean_rating = mean(user_rating),
		median_rating = median(user_rating),
		swear_word_count = sum(swear_word),
		swear_word_ratio = swear_word_count / n()
	)

compare_two <- function(char1, char2) {
	char_1 <- episodes_words %>% filter(character == char1)
	char_2 <- episodes_words %>% filter(character == char2)
	a <- char_1 %>% summarise(swear = sum(swear_word), total = n())
	b <- char_2 %>% summarise(swear = sum(swear_word), total = n())
	prop.test(rbind(a, b) %>% as.matrix(), correct = FALSE) %>%
		tidy() %>%
		cbind(character = char2)
}

others <- episodes_words %>%
	group_by(character) %>%
	count(character) %>%
	arrange(desc(n)) %>%
	ungroup() %>%
	top_n(20) %>%
	select(character) %>%
	unlist(use.names = FALSE)

superheroes <- c("coon", "mysterion", "toolshed", "the human kite", "professor chaos")

res <- lapply(superheroes, function(x) {
	compare_two("coon", x)
}) %>% bind_rows()

ggplot(res, aes(x = reorder(character, estimate2), estimate2)) +
	geom_errorbar(aes(ymin = conf.low, ymax = conf.high, col = p.value < 0.05)) +
	geom_hline(yintercept = 0, col = "red", linetype = "dashed") +
	theme(axis.text.x = element_text(angle = 60, hjust = 1))




