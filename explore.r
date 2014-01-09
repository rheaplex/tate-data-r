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

artwork.movement<-read.csv("../tate-data/artwork-movements.csv")
artwork.subjects<-read.csv("../tate-data/artwork-subjects.csv")
artwork.subjects.sentiment<-
    read.csv("../tate-data/artwork-subjects-sentiment.csv")
artwork.title.sentiment<-read.csv("../tate-data/artwork-title-sentiment.csv")

movement.artist.links<-read.csv("../tate-data/movement-artist-links.csv")
movement.subjects<-read.csv("../tate-data/movement-subjects.csv")

artist.subjects.corpus<-read.csv("../tate-data/artist-subjects-corpus.csv")
artist.titles.corpus<-read.csv("../tate-data/artist-titles-corpus.csv")
artwork.subjects.corpus<-read.csv("../tate-data/artwork-subjects-corpus.csv")
movement.subjects.corpus<-read.csv("../tate-data/movement-subjects-corpus.csv")
movement.titles.corpus<-read.csv("../tate-data/movement-titles-corpus.csv")

################################################################################
## Extract and generate some useful data
################################################################################

eras<-unique(artwork.movement$movement.era.name)
movements<-unique(artwork.movement$movement.name)

categories<-unique(artwork.subjects$category.name)
subcategories<-unique(artwork.subjects$subcategory.name)
subjects<-unique(artwork.subjects$subject.name)

artist.birth.decade<-round(artist$yearOfBirth, digits=-1)
artist.birth.century<-round(artist$yearOfBirth, digits=-2)
artist.death.decade<-round(artist$yearOfDeath, digits=-1)
artist.death.century<-round(artist$yearOfDeath, digits=-2)

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
## Centuries
summary(artist.birth.century)
summary(artist.death.century)

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
amagt<-table(artist.movements$movement.name, artist.movements$artist.gender)
#### Sort by Female
amagt<-amagt[order(amagt[,2], decreasing=TRUE),]
#### Show first 20
amagt[1:20,]

## Artwork

summary(artwork)
summary(artwork$year)
summary(artwork$width)[1:20]
summary(artwork$height)[1:20]

## Artwork movement

summary(artwork.movement)
summary(artwork.movement$movement.name)[1:20]
summary(artwork.movement$movement.era.name)

## Artwork subject

summary(artwork.subjects)
summary(artwork.subjects$category.name)[1:20]
summary(artwork.subjects$subcategory.name)[1:20]
summary(artwork.subjects$subject.name)[1:20]

## Artist subjects

## Movement subjects



################################################################################
## Movement Artwork Counts
################################################################################

artwork.movement.year<-data.frame(
    id=artwork.movement$artwork.id,
    year=artwork$year[match(artwork.movement$artwork.id, artwork$id)],
    movement=artwork.movement$movement.name)

movementYearsFrequency<-function(movement) {
    rle(sort(artwork.movement.year$year[artwork.movement.year$movement %in%
                                            movement]))
}

freqs<-do.call(rbind,
               lapply(names(summary(artwork.movement$movement.name)[1:20]),
                      function(movement) {
                          frequencies<-movementYearsFrequency(movement)
                          data.frame(Movement=rep(movement,
                                         length(frequencies$values)),
                                     Year=frequencies$values,
                                     Count=frequencies$lengths,
                                     stringsAsFactors=FALSE)
}))


ggplot(data=freqs,
       aes(x=Year, y=Count, group=Movement, fill=Movement, colour=Movement)) +
    geom_area(position="stack", stat="identity") + ##geom_line() +
    ggtitle("Movements")

plotMovementFrequency<-function(movement) {
    movement.years<-movementYearsFrequency(movement)
    plot(movement.years$values, movement.years$lengths, type="l", xlab="Year",
         ylab="Works", main=movement)

    ggplot(data=mdf, aes(x=Year, y=value, group = Company, colour = Company)) +
    geom_line()
}

plotMovementFrequency("Constructivism")
plotMovementFrequency("Young British Artists (YBA)")

        
################################################################################
## Movement Artwork Sizes
################################################################################

################################################################################
## Plot movement durations
################################################################################

movementDuration<-function(movement) {
    matching.indexes<-artwork.movement$movement.name == movement
    artworks.for.movement<-artwork.movement[matching.indexes,]
    c(from=min(artworks.for.movement$year, na.rm=TRUE),
      to=max(artworks.for.movement$year, na.rm=TRUE))
}

movements.from.to<-do.call(rbind, lapply(movements, movementDuration))
movement.durations<-data.frame(movement=as.character(movements),
                               from=movements.from.to[,"from"],
                               to=movements.from.to[,"to"],
                               stringsAsFactors=FALSE)

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
                                levels=unique(movement.durations.alpha$movement),
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
## Plot links between movements by artists
################################################################################

## Copy the node's color to edges emerging from it

edgeColoursFromNodes <- function(g) {
    from <- get.edges(g, E(g))[,1]
    E(g)$color <- V(g)$color[from]
}

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

links<-movement.artist.links[c("first.movement.name", "second.movement.name")]
movement.artist.links.graph<-to.graph(links)

pdf(file="movement-artist-links.pdf", width=8, height=8)
plot.graph(movement.artist.links.graph, identity)
dev.off()


################################################################################
## Genres
################################################################################

## Artworks by subjects

## Artworks by title

## Artists by subjects

## Artists by titles

################################################################################
## Movements
################################################################################

## Movement by medium
