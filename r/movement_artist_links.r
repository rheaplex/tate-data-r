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

library(igraph)

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

plotMovementArtistLinks <- function () {
    plot.graph(movement.artist.links.graph, identity)
}

plotMovementArtistLinksPDF <- function (filename) {
    pdf(file=filename, width=8, height=8)
    plotMovementArtistLinks()
    dev.off()
}

## plotMovementArtistLinksPDF("movement-artist-links.pdf")
