#' Fetch IMDB ratings for all South Park episodes.
#'
#' Downloads and parses basic information and ratings
#' about every South Park episode. It uses the only
#' official way that allows you to get data directly
#' from IMDB - \url{https://datasets.imdbws.com/}.
#'
#' The function downloads, parses and joins three of these files:
#' \emph{title.episode.tsv.gz}, \emph{title.basics.tsv.gz} and \emph{title.ratings.tsv.gz}.
#'
#' @param force_download If \code{TRUE} (default \code{FALSE}), download new IMDB files even
#'   if there are cached files.
#' @param make_rds If \code{TRUE} (default \code{TRUE}), automatically saves fetched and parsed
#'   data to \emph{ratings.rds} in a current working directory.
#' @param delete_files If \code{TRUE} (default \code{FALSE}), deletes downloaded files after
#'   processing.
#'
#' @return Data frame with following columns:
#'   \describe{
#'     \item{episode_imdb_id}{IMDB ID that identifies an episode, movie or TV show.}
#'     \item{season_number}{Season number.}
#'     \item{season_episode_number}{Episode number in a season.}
#'     \item{episode_name}{Name of the episode.}
#'     \item{air_date}{Year when the episode aired.}
#'     \item{user_rating}{Weighted average of user ratings.}
#'     \item{user_votes}{Number of user votes.}
#'   }
#' @export
fetch_ratings <- function(force_download = FALSE, make_rds = TRUE, delete_files = FALSE) {
	sp_imdb_id <- "tt0121955"
	file_names <- c("title.episode.tsv.gz", "title.basics.tsv.gz", "title.ratings.tsv.gz")

	if (force_download == TRUE | any(!file.exists(file_names))) {
		# Roughly 18 MB (84 MB unzipped) - episode-season link
		download.file("https://datasets.imdbws.com/title.episode.tsv.gz", destfile = "title.episode.tsv.gz")
		# Roughly 89 MB (418 MB unzipped) - title information (parsing failures)
		download.file("https://datasets.imdbws.com/title.basics.tsv.gz", destfile = "title.basics.tsv.gz")
		# Roughly 4 MB - ratings
		download.file("https://datasets.imdbws.com/title.ratings.tsv.gz", destfile = "title.ratings.tsv.gz")
	}

	episode_rel_links <- readr::read_tsv(gzfile(file_names[1]))
	episode_information <- readr::read_delim(gzfile(file_names[2]), delim = "\t", na = "\\N", escape_double = FALSE)
	episode_ratings <- readr::read_tsv(gzfile(file_names[3]))

	result <- filter(
		episode_rel_links,
		parentTconst == sp_imdb_id
	) %>%
		left_join(
			episode_information,
			by = "tconst"
		) %>%
		left_join(
			episode_ratings,
			by = "tconst"
		) %>%
		mutate(
			episode_imdb_id = tconst,
			season_number = as.numeric(seasonNumber),
			season_episode_number = as.numeric(episodeNumber),
			episode_name = primaryTitle,
			air_date = startYear,
			user_rating = averageRating,
			user_votes = numVotes
		) %>%
		select(
			episode_imdb_id, season_number, season_episode_number,
			episode_name, air_date, user_rating, user_votes
		)

	if (delete_files == TRUE) {
		unlink(file_names)
	}

	if (make_rds == TRUE) {
		readr::write_rds(result, "ratings.rds")
	}

	return(result)
}

#' Fetch IMDB ratings for one season.
#'
#' **DO NOT USE** - it violates IMDB conditions of use. It does
#'   not allow web scraping. It provides datasets that can
#'   be parsed accordingly.
#'
#' @seealso \code{\link{fetch_ratings}()} - use this function insted.
#'
#' @param season_number Numeric season number.
fetch_season_ratings_old <- function(season_number) {
	rating_url <- paste0("https://www.imdb.com/title/tt0121955/episodes?season=", season_number)
	html <- xml2::read_html(rating_url)

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
#' **DO NOT USE** - it violates IMDB conditions of use. It does
#'   not allow web scraping. It provides datasets that can
#'   be parsed accordingly.
#'
#' @seealso \code{\link{fetch_ratings}()} - use this function insted.
#'
#' @param season_number Numeric season number.
fetch_ratings_old <- function(season_numbers) {
	result <- purrr::map_df(season_numbers, fetch_season_ratings)

	return(result)
}
