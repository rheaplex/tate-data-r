## explore.r : exploring the Tate Collection dataset
##
## Copyright (c) 20013 Rob Myers <rob@robmyers.org>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## minara is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

library(grid)
library(igraph)
library(ggplot2)
library(tm)

################################################################################
## Load the data
################################################################################

artist<-read.csv("../tate-data/collection/artist_data.csv")
artwork<-read.csv("../tate-data/collection/artwork_data.csv")

artist.locations<-read.csv("../tate-data/artist-locations.csv")
artist.movements<-read.csv("../tate-data/artist-movements.csv")
artist.subjects<-read.csv("../tate-data/artist-subjects.csv")

artwork.movements<-read.csv("../tate-data/artwork-movements.csv")
artwork.subjects<-read.csv("../tate-data/artwork-subjects.csv")
artwork.subjects.sentiment<-
    read.csv("../tate-data/artwork-subjects-sentiment.csv")
artwork.title.sentiment<-read.csv("../tate-data/artwork-title-sentiment.csv")

movement.artist.links<-read.csv("../tate-data/movement-artist-links.csv")
movement.subjects<-read.csv("../tate-data/movement-subjects.csv")

artist.subjects.corpus<-read.csv("../tate-data/artist-subjects-corpus.csv",
                                 stringsAsFactors=FALSE)
artist.titles.corpus<-read.csv("../tate-data/artist-titles-corpus.csv",
                                 stringsAsFactors=FALSE)
artwork.subjects.corpus<-read.csv("../tate-data/artwork-subjects-corpus.csv")
movement.subjects.corpus<-read.csv("../tate-data/movement-subjects-corpus.csv")
movement.titles.corpus<-read.csv("../tate-data/movement-titles-corpus.csv")

################################################################################
## Extract and generate some useful data
################################################################################

eras<-unique(artwork.movements$movement.era.name)
movements<-unique(artwork.movements$movement.name)

categories<-unique(artwork.subjects$category.name)
subcategories<-unique(artwork.subjects$subcategory.name)
subjects<-unique(artwork.subjects$subject.name)

artist.birth.decade<-round(artist$yearOfBirth, digits=-1)
artist.birth.century<-round(artist$yearOfBirth, digits=-2)
artist.death.decade<-round(artist$yearOfDeath, digits=-1)
artist.death.century<-round(artist$yearOfDeath, digits=-2)

artwork.year.min<-min(artwork$year, na.rm=TRUE)
artwork.year.max<-max(artwork$year, na.rm=TRUE)

################################################################################
## Basic stats
################################################################################

## Artist

summary(artist)

## Artist Dates

summary(artist$yearOfBirth)
summary(artist$yearOfDeath)
## decades
summary(artist.birth.decade)
summary(artist.death.decade)
sort(table(artist.birth.decade), decreasing=TRUE)
## Centuries
summary(artist.birth.century)
summary(artist.death.century)
sort(table(artist.birth.death), decreasing=TRUE)

## Artist Gender

summary(artist$gender)
## Decades
table(artist.birth.decade, artist$gender)
## Centuries
## Note the 2000s entries, for recent artist groups
table(artist.birth.century, artist$gender)

## Artist movements

summary(artist.movements)
summary(artist.movements$movement.era.name)
summary(artist.movements$movement.name)
## Gender
#### Era
table(artist.movements$movement.era.name, artist.movements$artist.gender)
#### Movement
movement.gender<-table(artist.movements$movement.name,
                       artist.movements$artist.gender)
#### Sort by Female
movement.gender<-movement.gender[order(movement.gender[,2], decreasing=TRUE),]
#### Show first 20
movement.gender[1:20,]

## Artwork

summary(artwork)
summary(artwork$year)
summary(artwork$width)[1:20]
summary(artwork$height)[1:20]

## Artwork movement

summary(artwork.movements)
summary(artwork.movements$movement.name)[1:20]
summary(artwork.movements$movement.era.name)

## Artwork subject

summary(artwork.subjects)
summary(artwork.subjects$category.name)[1:20]
summary(artwork.subjects$subcategory.name)[1:20]
summary(artwork.subjects$subject.name)[1:20]

## Artist subjects

summary(artist.subjects)
summary(artist.subjects$category.name)[1:20]
summary(artist.subjects$subcategory.name)[1:20]
summary(artist.subjects$subject.name)[1:20]

## Movement subjects

summary(movement.subjects)
summary(movement.subjects$category.name)[1:20]
summary(movement.subjects$subcategory.name)[1:20]
summary(movement.subjects$subject.name)[1:20]

################################################################################
## Movement Artwork Counts
################################################################################

## Get the artworks for the movement name

movementYearsFrequency<-function(movement.name) {
    artworks.for.movement.<-artwork.movements$movement.name %in% movement.name
    rle(sort(artwork.movements$year[artworks.for.movement]))
}

## We don't want every movement, as it quickly becomes an unreadable mess
## 1:16 > 100
## 1:30 > 50
top.few.movements<-names(summary(artwork.movements$movement.name)[1:16])

## geom_area() needs entries for every year, and every moment, in order
## So we make a table of years/movements for which we have entries,
## then we make a table of all years/movements, with 0 as the count
## and then we combine them and remove duplicates (the 0s are the duplicates).

pop.freqs<-do.call(rbind,
                   lapply(top.few.movements,
                          function(movement) {
                              frequencies<-movementYearsFrequency(movement)
                              data.frame(Movement=rep(movement,
                                             length(frequencies$values)),
                                          Year=frequencies$values,
                                         Count=frequencies$lengths,
                                         stringsAsFactors=FALSE)
                          }))

empty.freqs<-do.call(rbind,
                     lapply(artwork.year.min:artwork.year.max,
                            function(year) {
                                data.frame(Movement=top.few.movements,
                                           Year=year,
                                           Count=0,
                                           stringsAsFactors=FALSE)
                            }))

## Combine the tables, zeros second so they are considered the duplicates
freqs<-rbind(pop.freqs, empty.freqs)
## Remove duplicates, leaving zero entries only where there is no count
freqs<-freqs[! duplicated(freqs[c("Movement", "Year")]),]
## Order by year and movement so geom_area is happy
freqs<-freqs[order(freqs$Year, freqs$Movement),]
## REMOVE IF INTERESTED IN EARLIER ENTRIES
## Concentrate on the bulk of the collection
freqs<-freqs[freqs$Year >= 1800,]

pdf(file="movement-work-count.pdf", width=20, height=10)
ggplot(data=freqs,
       aes(x=Year, y=Count, fill=Movement)) +
    geom_area(group=freqs$Movement, position = "stack") +
    scale_y_continuous(name="Total Number of Artworks")
    ggtitle("Number Of Artworks Per Year By Movement In The Tate Collection")
dev.off()

plotMovementFrequency<-function(movement) {
    movement.years<-movementYearsFrequency(movement)
    plot(movement.years$values, movement.years$lengths, type="l", xlab="Year",
         ylab="Works", main=movement)
}

pdf(file="yba-work-count.pdf", width=20, height=10)
plotMovementFrequency("Young British Artists (YBA)")
dev.off()

################################################################################
## Artwork Sizes
################################################################################

## Artist

## Movement

## Medium

## Subject


################################################################################
## Medium
################################################################################

## Artist

## Movement

## Subject (need to add medium column)

################################################################################
## Movement durations
################################################################################

## Find when the movement started and ended
## or at least when the first and last works in the collection for that movement
## date to.

movementDuration<-function(movement) {
    matching.indexes<-artwork.movements$movement.name == movement
    artworks.for.movement<-artwork.movements[matching.indexes,]
    c(from=min(artworks.for.movement$year, na.rm=TRUE),
      to=max(artworks.for.movement$year, na.rm=TRUE))
}

## Make a frame of movement durations

movements.from.to<-do.call(rbind, lapply(movements, movementDuration))
movement.durations<-data.frame(movement=as.character(movements),
                               from=movements.from.to[,"from"],
                               to=movements.from.to[,"to"],
                               stringsAsFactors=FALSE)

## Plot movement durations with the movments in the specified order
## e.g. alphabetically, or by when they start or end

plotMovementDurations<-function(movement.data, movement.order) {
    to.plot<-data.frame(fromto=ggplot2:::interleave(movement.data$from,
                            movement.data$to),
                        movement=ggplot2:::interleave(movement.data$
                            movement,
                            rep("", length(movement.data$to))),
                        y.order=movement.order)
    ggplot(to.plot, aes(x=fromto, y=y.order)) +
      geom_line() +
      geom_point(size=1) +
      ## Move the text to avoid the dots, and scale it down to pack it in
      geom_text(aes(label=movement), size=2, hjust=0, vjust=-0.6) +
      ## Right pad to avoid cropping labels
      xlim(c(min(to.plot$fromto), max(to.plot$fromto) + 10)) +
      ## Top pad to avoid cropping labels
      scale_y_discrete(expand=c(0, 2)) +
      labs(x=NULL, y=NULL) +
      theme_bw() +
      theme(axis.ticks=element_blank(), axis.text.y=element_blank(),
            panel.border=element_blank(),
            panel.grid.major.y = element_blank())
}

## Plot movements alphabetically

## Sort by reverse alphabet order so A is at the top of the plot
movement.durations.alpha<-movement.durations[order(movement.durations$movement,
                                                   decreasing=TRUE),]
movement.order.alpha<-rep(factor(movement.durations.alpha$movement,
                                 levels=unique(movement.durations.alpha$
                                     movement),
                                 ordered=TRUE), each=2)
pdf(file="movement-durations-name.pdf", width=10, height=20)
plotMovementDurations(movement.durations.alpha, movement.order.alpha)
dev.off()

## Plot movements by start date

## Sort by date
movement.durations.from<-movement.durations[order(movement.durations$from),]
movement.order.from<-rep(factor(movement.durations.from$movement,
                                levels=unique(movement.durations.from$movement),
                                ordered=TRUE), each=2)
pdf(file="movement-durations-era.pdf", width=10, height=20)
plotMovementDurations(movement.durations.from, movement.order.from)
dev.off()

################################################################################
## Links between movements by artists
################################################################################

## Copy the node's color to edges emerging from it

edgeColoursFromNodes <- function(g) {
    from <- get.edges(g, E(g))[,1]
    E(g)$color <- V(g)$color[from]
}

## Plot the graph g with its names transformed by nameFun
## pass identity for untransformed names

plot.graph <- function (g, nameFun) {
    ## We scale various properties by degree, so we get degree and max for this
    degrees <- degree(g)
    max.degree <- max(degrees)

    ## Scale sizes and colours of vertexes by degree
    vertex.label.sizes <- 0.3 + (degrees * (0.7 / max.degree))
    ## 15 is the default - http://igraph.sourceforge.net/doc/R/plot.common.html
    vertex.sizes <- (0.3 + (degrees * (0.7 / max.degree))) * 5
    
    par(bg="white")
    par(mai=c(0,0,0,0)) 
    plot(g,
         ##edge.width=0.01,
         ## This refuses to work as an edge property
         edge.color=edgeColoursFromNodes(g), ##"lightgray",
         edge.arrow.size=0.05,
         edge.curved=FALSE,
         vertex.size=vertex.sizes,
         vertex.frame.color=NA,
         ##vertex.color="lightgray",
         vertex.label=nameFun(V(g)$name),
         vertex.label.family="sans",
         vertex.label.font=2, ## bold
         vertex.label.cex=vertex.label.sizes,
         vertex.label.color="black",
         )
}

## Convert the relationship table to a graph suitable for plotting

to.graph <- function (relationships) {
    ## Create a graph from the table
    g <- graph.edgelist(as.matrix(relationships), directed=TRUE)
    ## Simplify the graph to remove loops
    g <- simplify(g, remove.multiple=FALSE)

    ## Remove small unconnected graphs / islands
    cl <- clusters(g)
    g <- subgraph(g, cl$membership == 1)

    ##membership <- clusters(g)$membership
    communityMembership <- spinglass.community(g)
    membershipColours <- rainbow(max(communityMembership$membership),
                                 alpha=0.7)
    V(g)$color <- membershipColours[communityMembership$membership]
    
    g$layout <- layout.fruchterman.reingold(g, niter=666, area=vcount(g)^2.3,
                                            repulserad=vcount(g)^2.75)
    
    g
}

## Convert the links between movements that artists were in to a graph and plot

links<-movement.artist.links[c("first.movement.name", "second.movement.name")]
movement.artist.links.graph<-to.graph(links)

pdf(file="movement-artist-links.pdf", width=8, height=8)
plot.graph(movement.artist.links.graph, identity)
dev.off()

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
findFreqTerms(artist.subjects.dtm, 4)

similarEntities(artist.subjects.dtm, artist.subjects.corpus$artist.name)

## Artists by titles

## "Movement" by artist/medium (&....) ?
