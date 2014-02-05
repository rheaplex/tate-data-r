## r-tate-data : exploring the Tate Collection dataset with R
## Copyright (c) 2013,2014 Rob Myers <rob@robmyers.org>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

library(tm)

source("load_tate_data.r")

################################################################################
## Genres
################################################################################

## Clean text
cleanArticle<-function(text){
    ## Remove punctuation
    text<-lapply(text, function(line){gsub("[[:punct:]]", "", line)})
    ## Lowercase words
    text<-lapply(text, tolower)
    text
}

## Similar entities

similarEntities<-function(dtm, names) {
    # Dissimilarity
    dis<-dissimilarity(dtm, method="cosine")
    ## The most similar for each, in order of similarity
    similarityMin<-0.25
    mostSimilarEnities<-apply(dis, 1,
                       function(row){
                           sorted<-sort(row)
                           ordered<-order(row)
                           ## 0.0 == same entity
                           ordered[sorted > 0.0 & sorted < similarityMin]
                       })
    for(doc in 1:length(mostSimilarEntities)){
        mostSimilar<-unlist(mostSimilarEntities[doc])
        if(length(mostSimilar) > 0){
            count<-min(length(mostSimilar), 5)
            similar<-paste(names[mostSimilar[1:count]], collapse=", ")
        }else{
            similar<-"None"
        }
        cat(names[[doc]], ": ", similar, "\n\n")
    }
}

## Artworks by subjects

## Artworks by title

## Artists by subjects

artist.subjects.corpus.clean<-lapply(artist.subjects.corpus$subjects,
                                     cleanArticle)
artist.subjects.corpus.corpus<-Corpus(VectorSource(artist.subjects.corpus.clean),
                                      readerControl=list(language="english",
                                          reader=readPlain))
## Term/document matrix
artist.subjects.dtm<-DocumentTermMatrix(artist.subjects.corpus.corpus)

## Frequent terms in the matrix
artistSubjectsFreqTerms <- function (freq) {
    findFreqTerms(artist.subjects.dtm, freq)
}

artistSimilarEntities <- function () {
    similarEntities(artist.subjects.dtm, artist.subjects.corpus$artist.name)
}

## Artists by titles

## "Movement" by artist/medium (&....) ?


## artistSubjectsFreqTerms(1500)
## artistSimilarEntities()
