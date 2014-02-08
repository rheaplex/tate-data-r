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

library(ggplot2)

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

plotMovementDurationsNamePDF <- function (filename) {
    pdf(file=filename, width=10, height=20)
    plotMovementDurations(movement.durations.alpha, movement.order.alpha)
    dev.off()
}

## Plot movements by start date

## Sort by date
movement.durations.from<-movement.durations[order(movement.durations$from),]
movement.order.from<-rep(factor(movement.durations.from$movement,
                                levels=unique(movement.durations.from$movement),
                                ordered=TRUE), each=2)

plotMovementDurationsEraPDF <- function (filename) {
    pdf(file=filename, width=10, height=20)
    plotMovementDurations(movement.durations.from, movement.order.from)
    dev.off()
}

## plotMovementDurationsNamePDF("movement-durations-name.pdf")
## plotMovementDurationsEraPDF("movement-durations-era.pdf")
