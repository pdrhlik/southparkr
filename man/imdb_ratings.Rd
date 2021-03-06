% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/datasets.R
\docType{data}
\name{imdb_ratings}
\alias{imdb_ratings}
\title{IMDB episode ratings}
\format{A data frame with 308 rows and 7 variables.}
\source{
\url{https://www.imdb.com/interfaces/}
}
\usage{
imdb_ratings
}
\description{
A dataset containing information about South Park episodes,
  seasons they belong to and links to their scripts. It can
  be recreated using \code{\link{fetch_episode_list}()}. There
  are episodes which have an \code{NA} rating. That is because
  those haven't aired yet. There is also one rated episode
  for which we don't have any scripts. It is an "Unaired Pilot"
  that belongs to season 1 and has an episode number 0.
}
\details{
\describe{
  \item{episode_imdb_id}{IMDB episode ID.}
  \item{season_number}{Numeric number of a season.}
  \item{season_episode_number}{Numeric number of a season.}
  \item{episode_name}{Official name of an episode.}
  \item{air_date}{A year when an episode was released.}
  \item{user_rating}{Average weighted user rating of an episode.}
  \item{user_votes}{Number of votes for an episode.}
}
}
\keyword{datasets}
