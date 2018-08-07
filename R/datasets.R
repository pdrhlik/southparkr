#' Basic information about episodes
#'
#' A dataset containing information about South Park episodes,
#'   seasons they belong to and links to their scripts. It can
#'   be recreated using \code{\link{fetch_episode_list}()}.
#'
#' \describe{
#'   \item{season_episode_number}{Number of an episode in a season.}
#'   \item{season_link}{
#'     URL link to a page of season scripts. That page contains
#'     a list of episodes and links to their transcripts.
#'     Example: \url{http://southpark.wikia.com/wiki/Portal:Scripts/Season_One"}}
#'   \item{episode_link}{
#'     URL link to an episode transcript.
#'     Example: \url{http://southpark.wikia.com/wiki/Cartman_Gets_an_Anal_Probe/Script}}
#'   \item{episode_name}{Official name of an episode.}
#'   \item{season_name}{String in a format: Season ___ (number as a word).}
#'   \item{season_number}{Numeric number of a season.}
#'   \item{season_year}{A year when an episode was released.}
#' }
#'
#' @docType data
#' @source \url{https://southpark.wikia.com/wiki/Portal:Scripts}
#' @format A data frame with 287 rows and 7 variables.
"episode_list"

#' Lines spoken by characters
#'
#' A dataset containing lines spoken by characters in an episode.
#'  It can be recreated using \code{\link{fetch_all_episodes}()}.
#'
#' \describe{
#'   \item{character}{Name of a character.}
#'   \item{text}{One line of text spoken by character in an episode.}
#'   \item{episode_link}{
#'     URL link to an episode transcript.
#'     Example: \url{http://southpark.wikia.com/wiki/Cartman_Gets_an_Anal_Probe/Script}}
#'   \item{season_episode_number}{Number of an episode in a season}
#'   \item{season_link}{
#'     URL link to a page of season scripts. That page contains
#'     a list of episodes and links to their transcripts.
#'     Example: \url{http://southpark.wikia.com/wiki/Portal:Scripts/Season_One"}}
#'   \item{episode_name}{Official name of an episode.}
#'   \item{season_name}{String in a format: Season ___ (number as a word).}
#'   \item{season_number}{Numeric number of a season.}
#'   \item{season_year}{A year when an episode was released.}
#' }
#'
#' @docType data
#' @source \url{https://southpark.wikia.com/wiki/Portal:Scripts}
#' @format A data frame with 78701 rows and 9 variables.
"episode_lines"

#' IMDB episode ratings
#'
#' A dataset containing information about South Park episodes,
#'   seasons they belong to and links to their scripts. It can
#'   be recreated using \code{\link{fetch_episode_list}()}. There
#'   are episodes which have an \code{NA} rating. That is because
#'   those haven't aired yet. There is also one rated episode
#'   for which we don't have any scripts. It is an "Unaired Pilot"
#'   that belongs to season 1 and has an episode number 0.
#'
#' \describe{
#'   \item{episode_imdb_id}{IMDB episode ID.}
#'   \item{season_number}{Numeric number of a season.}
#'   \item{season_episode_number}{Numeric number of a season.}
#'   \item{episode_name}{Official name of an episode.}
#'   \item{air_date}{A year when an episode was released.}
#'   \item{user_rating}{Average weighted user rating of an episode.}
#'   \item{user_votes}{Number of votes for an episode.}
#' }
#'
#' @docType data
#' @source \url{https://www.imdb.com/interfaces/}
#' @format A data frame with 308 rows and 7 variables.
"imdb_ratings"
