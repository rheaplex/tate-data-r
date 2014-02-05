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

library(grid)
library(ggplot2)

source("load_tate_data.r")

################################################################################
## Movement Artwork Counts
################################################################################

## Get the artworks for the movement name

movementYearsFrequency<-function(movement.name) {
    artworks.for.movement<-artwork.movements$movement.name %in% movement.name
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

plotArtworkCountsByYear <- function () {
    p <- ggplot(freqs,
                aes(x=Year, y=Count, fill=Movement)) +
                    geom_area(group=freqs$Movement, position = "stack") +
                        scale_y_continuous(name="Total Number of Artworks")
    p + ggtitle("Number Of Artworks Per Year By Movement In The Tate Collection")
}

plotArtworkCountsByYearPDF <- function (filename) {
    pdf(file=filename, width=20, height=10)
    plotArtworkCountsByYear()
    dev.off()
}

plotMovementFrequency<-function(movement) {
    movement.years<-movementYearsFrequency(movement)
    plot(movement.years$values, movement.years$lengths, type="l", xlab="Year",
         ylab="Works", main=movement)
}

plotMovementArtworkCountPDF <- function (movement, filename) {
    pdf(file=filename, width=20, height=10)
    plotMovementFrequency(movement)
    dev.off()
}

## plotMovementArtworkCountPDF("yba-work-count.pdf", "Young British Artists (YBA)")
## plotArtworkCountsByYearPDF("movement-work-count.pdf")
