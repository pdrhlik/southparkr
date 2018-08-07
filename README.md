# southparkr <img src="sticker/southparkr-sticker.png" align="right" width="150" />

[![Build Status](https://travis-ci.org/pdrhlik/southparkr.svg?branch=master)](https://travis-ci.org/pdrhlik/southparkr)

The package is used to scrape South Park transcripts and IMDB ratings for each episode. The processed data can then be used in a text analysis.

## About South Park

[South Park](https://en.wikipedia.org/wiki/South_Park) is an American, satiric, animated TV show about four elementary school boys. Those are just the main characters. There is a lot more throughout the series. Pretty much everybody famous has already been made fun of by South Park creators [Trey Parker](https://en.wikipedia.org/wiki/Trey_Parker) and [Matt Stone](https://en.wikipedia.org/wiki/Matt_Stone). You can watch all the episodes for free on their official site [https://southpark.cc.com](http://southpark.cc.com/full-episodes). Well, at least in the Czech Republic.

## Installation

The development version can be installed using [devtools](https://github.com/r-lib/devtools):

```
devtools::install_github("pdrhlik/southparkr")
```

## Scraping South Park scripts

The main resource for South Park scripts is a community driven website [https://southpark.wikia.com/](https://southpark.wikia.com/). There is a subsection [Portal:Scripts](https://southpark.wikia.com/wiki/Portal:Scripts) that has a unified table of scripts for each episode.

```
episode_list <- fetch_episode_list()
episode_lines <- fetch_all_episodes(episode_list)
```

## Scraping IMDB ratings

This is done by parsing official [IMDB interfaces](https://www.imdb.com/interfaces/). South Park IMDB ID is `tt0121955`. It is used to get IMDB IDs of every South Park episode from the file [title.episode.tsv.gz](https://datasets.imdbws.com/title.episode.tsv.gz). Once the IDs are obtained, it gathers episode information from [title.basics.tsv.gz](https://datasets.imdbws.com/title.basics.tsv.gz) and episode ratings from [title.ratings.tsv.gz](https://datasets.imdbws.com/title.ratings.tsv.gz).

```
imdb_ratings <- fetch_ratings()
```

## Usage

It contains 3 precomputed datasets - `episode_list`, `episode_lines` and `imdb_ratings`. It also has a set of functions that can recreate these datasets. That should be done when new episodes are created. You can experiment with those functions on your own but remember that it takes quite a lot of time.

The following function can be used to process prepared datasets. It will create a new dataset where each row will be a word. It will also add a `sentiment_score`, `word_stem` and a `swear_word` logical flag.

```
episode_words <- process_episode_words(episode_lines, imdb_ratings, keep_stopwords = FALSE)
```

## Analysis

I used the package to answer two hypotheses. The functions I used are in `R/analyses.R` and `R/plots.R` files.

1. Are naughty episodes more popular?
2. Is Eric Cartman the naughtiest character in the show?

You can try to answer these yourself!

I will be writing an article about my findings. I wrote a first part that describes how I obtained the data in more detail on my blog: [South Park Analysis I - Script Scraping](https://patrio.blog/south-park-analysis-i-script-scraping/).

I also gave a talk about my findings at the [Why R? 2018 conference](http://whyr2018.pl/). You can check the [slides](https://pdrhlik.github.io/southparktalk-whyr2018/) yourself!
