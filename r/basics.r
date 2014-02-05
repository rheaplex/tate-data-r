b## r-tate-data : exploring the Tate Collection dataset with R
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

source("load_tate_data.r")

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
