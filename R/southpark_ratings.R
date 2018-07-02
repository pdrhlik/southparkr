#' Fetch IMDB ratings for one season.
#'
#' @param season_number
#'
#' @export
fetch_season_ratings <- function(season_number) {
	rating_url <- paste0("https://www.imdb.com/title/tt0121955/episodes?season=", season_number)
	html <- rvest::read_html(rating_url)

	ratings <- dplyr::data_frame(
		season_number = season_number,
		season_episode_number = rvest::html_nodes(html, ".list_item .image div div") %>%
			rvest::html_text() %>%
			stringr::str_extract("\\d+$") %>%
			as.numeric(),
		episode_name = rvest::html_nodes(html, ".list_item .info strong a") %>%
			rvest::html_text(),
		air_date = rvest::html_nodes(html, ".list_item .info .airdate") %>%
			rvest::html_text() %>%
			lubridate::dmy(),
		user_rating = rvest::html_nodes(html, "#episodes_content > div.clear > div.list.detail.eplist > div.list_item > div.info > div.ipl-rating-widget > div.ipl-rating-star > span.ipl-rating-star__rating") %>%
			rvest::html_text() %>%
			as.numeric(),
		user_votes = rvest::html_nodes(html, "#episodes_content > div.clear > div.list.detail.eplist > div.list_item > div.info > div.ipl-rating-widget > div.ipl-rating-star > span.ipl-rating-star__total-votes") %>%
			rvest::html_text() %>%
			stringr::str_replace_all("[^0-9]", "") %>%
			as.numeric()
	)

	return(ratings)
}

#' Fetch ratings for all selected seasons.
#'
#' @param season_numbers
#' @export
fetch_ratings <- function(season_numbers) {
	result <- purrr::map_df(season_numbers, fetch_season_ratings)

	return(result)
}
