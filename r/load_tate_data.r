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

################################################################################
## Load the data
################################################################################

artist<-read.csv("../../tate-data/collection/artist_data.csv")
artwork<-read.csv("../../tate-data/collection/artwork_data.csv")

artist.locations<-read.csv("../../tate-data/artist-locations.csv")
artist.movements<-read.csv("../../tate-data/artist-movements.csv")
artist.subjects<-read.csv("../../tate-data/artist-subjects.csv")

artwork.movements<-read.csv("../../tate-data/artwork-movements.csv")
artwork.subjects<-read.csv("../../tate-data/artwork-subjects.csv")
artwork.subjects.sentiment<-
    read.csv("../../tate-data/artwork-subjects-sentiment.csv")
artwork.title.sentiment<-read.csv("../../tate-data/artwork-title-sentiment.csv")

movement.artist.links<-read.csv("../../tate-data/movement-artist-links.csv")
movement.subjects<-read.csv("../../tate-data/movement-subjects.csv")

artist.subjects.corpus<-read.csv("../../tate-data/artist-subjects-corpus.csv",
                                 stringsAsFactors=FALSE)
artist.titles.corpus<-read.csv("../../tate-data/artist-titles-corpus.csv",
                                 stringsAsFactors=FALSE)
artwork.subjects.corpus<-read.csv("../../tate-data/artwork-subjects-corpus.csv")
movement.subjects.corpus<-read.csv("../../tate-data/movement-subjects-corpus.csv")
movement.titles.corpus<-read.csv("../../tate-data/movement-titles-corpus.csv")

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
