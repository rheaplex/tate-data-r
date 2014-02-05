Exploring Tate Art Open Data 1
================================================================================




This is the first in a series of posts examining Tate's excellent collection dataset available at [http://www.tate.org.uk/about/our-work/digital/collection-data](http://www.tate.org.uk/about/our-work/digital/collection-data) .

I've processed that dataset using code for Mongo DB and Node.js available at [https://gitorious.org/robmyers/tate-data/](https://gitorious.org/robmyers/tate-data/) .

The R and R Markdown code for this series is available at [https://gitorious.org/robmyers/tate-data-r/](https://gitorious.org/robmyers/tate-data-r/) .

This document has been produced using [Knitr](http://yihui.name/knitr/). Text in light grey boxes is R code, text in white boxes is the output of that code.

Let's get started by loading the data.


```r
source("../r/load_tate_data.r")
```


That file reads the comma separated value (csv) files containing information about the Tate's collection and generates some useful extra tables of information. Now we have everything in memory we can start examining the collection data.

Artists
--------------------------------------------------------------------------------

What can we find out about artists in general?


```r
summary(artist[c("name", "gender", "dates", "yearOfBirth", "yearOfDeath", "placeOfBirth", 
    "placeOfDeath")])
```

```
              name         gender                 dates     
 Bateman, James :   2         : 112   dates not known:  59  
 Doyle, John    :   2   Female: 521   born 1967      :  42  
 Hone, Nathaniel:   2   Male  :2894   born 1936      :  38  
 Peri, Peter    :   2                 born 1930      :  36  
 Stokes, Adrian :   2                 born 1938      :  36  
 Wilson, Richard:   2                 born 1941      :  34  
 (Other)        :3515                 (Other)        :3282  
  yearOfBirth    yearOfDeath                      placeOfBirth 
 Min.   :1497   Min.   :1543                            : 491  
 1st Qu.:1855   1st Qu.:1874   London, United Kingdom   : 446  
 Median :1910   Median :1944   Paris, France            :  57  
 Mean   :1887   Mean   :1920   Edinburgh, United Kingdom:  47  
 3rd Qu.:1941   3rd Qu.:1982   New York, United States  :  43  
 Max.   :2004   Max.   :2013   Glasgow, United Kingdom  :  35  
 NA's   :57     NA's   :1309   (Other)                  :2408  
                    placeOfDeath 
                          :2079  
 London, United Kingdom   : 442  
 Paris, France            :  82  
 New York, United States  :  45  
 Roma, Italia             :  22  
 Edinburgh, United Kingdom:  18  
 (Other)                  : 839  
```

There are more male than female artists, and the yBA and Pop generations lead the births.

Depending on whether we treat place of birth or place of death as more representative, London and Paris are ahead of New York or Edinburgh.

We can smooth out the birth and death dates by grouping them by decade or century.


```r
summary(artist.birth.decade)
```

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
   1500    1860    1910    1890    1940    2000      57 
```

```r
summary(artist.death.decade)
```

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
   1540    1870    1940    1920    1980    2010    1309 
```

```r
sort(table(artist.birth.decade), decreasing = TRUE)
```

```
artist.birth.decade
1940 1930 1960 1920 1970 1900 1950 1910 1880 1890 1860 1870 1840 1780 1800 
 363  285  256  255  222  217  197  186  153  151  136  123   77   72   69 
1850 1820 1830 1980 1790 1810 1760 1770 1740 1750 1730 1700 1720 1710 1630 
  69   67   65   58   57   49   45   44   42   38   31   27   15   13   12 
1680 1640 1660 1600 1580 1590 1610 1650 1690 1620 1990 2000 1500 1530 1540 
  10    9    8    6    5    4    4    4    4    3    3    3    2    2    2 
1550 1560 1670 1570 
   2    2    2    1 
```

```r

summary(artist.birth.century)
```

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
   1500    1900    1900    1890    1900    2000      57 
```

```r
summary(artist.death.century)
```

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
   1500    1900    1900    1920    2000    2000    1309 
```

```r
sort(table(artist.death.decade), decreasing = TRUE)
```

```
artist.death.decade
2000 1980 1960 1990 1970 1940 2010 1920 1930 1950 1900 1910 1840 1860 1880 
 224  191  172  157  140  131  112  102   92   89   80   69   59   59   54 
1850 1870 1890 1820 1830 1800 1810 1780 1790 1700 1760 1770 1750 1720 1730 
  53   49   49   46   44   42   40   24   23   15   14   12   10    7    7 
1740 1680 1710 1640 1690 1620 1650 1660 1570 1670 1600 1630 1540 
   7    6    6    5    5    4    4    4    3    3    2    2    1 
```


That's quite a different result from that suggested by the yearly results. Decade-wise, birth percentiles are clustered around the turn of the 20th century, deaths around the second world war. But the largest number of births are in the 1930s/1940s with the 1960s coming in second. The deaths look like they reflect the distribution of births, although it would be useful to confirm this statistically.

The maximim birth being in the 2000s doesn't mean that the Tate is collecting child artists, the birth data also includes the years that artist groups were started.

How well is gender represented in the collection?


```r
table(artist.birth.decade, artist$gender)
```

```
                   
artist.birth.decade     Female Male
               1500   1      0    1
               1530   1      0    1
               1540   0      0    2
               1550   0      0    2
               1560   0      0    2
               1570   0      0    1
               1580   0      0    5
               1590   1      0    3
               1600   3      0    3
               1610   1      0    3
               1620   0      0    3
               1630   0      1   11
               1640   0      0    9
               1650   0      0    4
               1660   0      0    8
               1670   1      0    1
               1680   0      0   10
               1690   0      0    4
               1700   4      1   22
               1710   0      0   13
               1720   0      1   14
               1730   0      0   31
               1740   1      1   40
               1750   0      3   35
               1760   0      1   44
               1770   0      1   43
               1780   1      5   66
               1790   1      0   56
               1800  10      0   59
               1810   0      2   47
               1820   0      1   66
               1830   1      6   58
               1840   0      5   72
               1850   0      2   67
               1860   1     10  125
               1870   0     15  108
               1880   4     23  126
               1890   4     18  129
               1900   8     38  171
               1910   3     37  146
               1920   2     33  220
               1930   4     38  243
               1940  12     62  289
               1950   2     40  155
               1960   6     77  173
               1970   8     70  144
               1980   3     21   34
               1990   2      0    1
               2000   2      0    1
```

```r

table(artist.birth.century, artist$gender)
```

```
                    
artist.birth.century      Female Male
                1500    2      0    5
                1600    5      1   44
                1700    6      4  157
                1800   13     24  576
                1900   39    293 1667
                2000   22    190  422
```


The first, unlabelled, column is for artists whose gender is not currently recorded in the data.

As we saw in the summary, there are more male artists than female artists in the Tate's collection. There is no decade or century in which this trend is reversed. The story is slightly different when we look at artistic movements.

Movements
--------------------------------------------------------------------------------

The data for artists includes information on 

```

Error in movements$movement.name : 
  $ operator is invalid for atomic vectors

```

 artists movements. If we looked at the artwork data there might be more, but we'll stick with the artists for now. 


```r
summary(artist.movements[c("artist.fc", "artist.gender", "movement.era.name", 
    "movement.name")])
```

```
                       artist.fc   artist.gender
 Ben Nicholson OM           :  6         :  5   
 Dame Barbara Hepworth      :  5   Female: 27   
 Gilbert Soest              :  5   Male  :324   
 Joseph Beuys               :  5                
 Sir Peter Lely             :  5                
 British School 17th century:  4                
 (Other)                    :326                
              movement.era.name
 16th and 17th century : 47    
 18th century          : 27    
 19th century          : 63    
 20th century 1900-1945: 95    
 20th century post-1945:124    
                               
                               
                                 movement.name
 Performance Art                        : 14  
 Conceptual Art                         : 10  
 Netherlands-trained, working in Britain: 10  
 Constructivism                         :  9  
 Body Art                               :  8  
 British Surrealism                     :  8  
 (Other)                                :297  
```

```r
summary(artist.movements$movement.era.name)
```

```
 16th and 17th century           18th century           19th century 
                    47                     27                     63 
20th century 1900-1945 20th century post-1945 
                    95                    124 
```

```r
summary(artist.movements$movement.name)
```

```
                         Performance Art 
                                      14 
                          Conceptual Art 
                                      10 
 Netherlands-trained, working in Britain 
                                      10 
                          Constructivism 
                                       9 
                                Body Art 
                                       8 
                      British Surrealism 
                                       8 
                          St Ives School 
                                       8 
                         Victorian/Genre 
                                       8 
                    Abstraction-Création 
                                       7 
                         British War Art 
                                       7 
                                   Court 
                                       7 
                       Environmental Art 
                                       7 
                            Later Stuart 
                                       7 
                             Picturesque 
                                       7 
                              Surrealism 
                                       7 
                               Symbolism 
                                       7 
                              Abject art 
                                       6 
                                 Baroque 
                                       6 
                  British Constructivism 
                                       6 
                   British Impressionism 
                                       6 
                               Decadence 
                                       6 
                          Pre-Raphaelite 
                                       6 
                                Unit One 
                                       6 
                            Grand Manner 
                                       5 
                             Kinetic Art 
                                       5 
                                Land Art 
                                       5 
                              Minimalism 
                                       5 
                         Neo-Romanticism 
                                       5 
                                Tachisme 
                                       5 
                               Vorticism 
                                       5 
                      Aesthetic Movement 
                                       4 
                       Camden Town Group 
                                       4 
                      Conversation Piece 
                                       4 
                                  Cubism 
                                       4 
                            Feminist Art 
                                       4 
                        Geometry of Fear 
                                       4 
                       Neo-Expressionism 
                                       4 
                             Restoration 
                                       4 
                         Return to Order 
                                       4 
                          Seven and Five 
                                       4 
                                 Sublime 
                                       4 
                             British Pop 
                                       3 
              Civil War and Commonwealth 
                                       3 
                                    Dada 
                                       3 
                           Fancy Picture 
                                       3 
                           Fin de Siècle 
                                       3 
                           Impressionism 
                                       3 
                            London Group 
                                       3 
                    New English Art Club 
                                       3 
                      Post-Impressionism 
                                       3 
                                   Tudor 
                                       3 
             Young British Artists (YBA) 
                                       3 
                            Art Informel 
                                       2 
                             Art Nouveau 
                                       2 
                    Auto-Destructive art 
                                       2 
                          Direct Carving 
                                       2 
                      Euston Road School 
                                       2 
                          Neo-Classicism 
                                       2 
                          Neo-Plasticism 
                                       2 
                           Newlyn School 
                                       2 
                           New Sculpture 
                                       2 
                             Optical Art 
                                       2 
                                 Pop Art 
                                       2 
              Post Painterly Abstraction 
                                       2 
                                Regional 
                                       2 
                               Situation 
                                       2 
              Situationist International 
                                       2 
                  Abstract Expressionism 
                                       1 
                               Actionism 
                                       1 
                           Arte Nucleare 
                                       1 
                  Artist Placement Group 
                                       1 
       Artists International Association 
                                       1 
                                 Bauhaus 
                                       1 
                                   Cobra 
                                       1 
                        Der Blaue Reiter 
                                       1 
                                De Stijl 
                                       1 
                            Early Stuart 
                                       1 
English-born, working in the Netherlands 
                                       1 
                           Expressionism 
                                       1 
                                 Fauvism 
                                       1 
                                  Fluxus 
                                       1 
      French-trained, working in Britain 
                                       1 
                                Futurism 
                                       1 
                    German Expressionism 
                                       1 
                              Grand Tour 
                                       1 
                       Independent Group 
                                       1 
     Italian-trained, working in Britain 
                                       1 
                                    Merz 
                                       1 
                        Metaphysical Art 
                                       1 
                    Modern Moral Subject 
                                       1 
                          Modern Realism 
                                       1 
                       Neo-Impressionism 
                                       1 
                             Neue Wilden 
                                       1 
                   New British Sculpture 
                                       1 
                          Norwich School 
                                       1 
                        Nouveau Réalisme 
                                       1 
                             Orientalist 
                                       1 
                           Origine group 
                                       1 
                        Post-Reformation 
                                       1 
                                 (Other) 
                                       9 
```


The artists included in the most movements are some of the grand elders of British 20th Century art. Being in an art movement doesn't improve gender representation.

The most movements are post-1945. Performance art is more popular than Conceptual art, which is interesting given public discussion of state art funding in the UK. "Netherlands-trained, working in Britain" clearly isn't a movement, as with the birth dates the movement name field doesn't always describe a movement per se.

Let's break down gender by movement.


```r
table(artist.movements$movement.era.name, artist.movements$artist.gender)
```

```
                        
                             Female Male
  16th and 17th century    5      0   42
  18th century             0      0   27
  19th century             0      0   63
  20th century 1900-1945   0      9   86
  20th century post-1945   0     18  106
```

```r
movement.gender <- table(artist.movements$movement.name, artist.movements$artist.gender)
movement.gender <- movement.gender[order(movement.gender[, 2], decreasing = TRUE), 
    ]
movement.gender[1:20, ]
```

```
                             
                                Female Male
  Performance Art             0      5    9
  Feminist Art                0      4    0
  Abject art                  0      3    3
  Abstraction-Création        0      2    5
  Constructivism              0      2    7
  St Ives School              0      2    6
  Body Art                    0      1    7
  Camden Town Group           0      1    3
  Kinetic Art                 0      1    4
  Minimalism                  0      1    4
  Rayonism                    0      1    0
  Seven and Five              0      1    3
  Surrealism                  0      1    6
  Unit One                    0      1    5
  Young British Artists (YBA) 0      1    2
  Abstract Expressionism      0      0    1
  Actionism                   0      0    1
  Aesthetic Movement          0      0    4
  Arte Nucleare               0      0    1
  Art Informel                0      0    2
```


Representation improves slightly over time. Unsurprisingly, feminist art has more female than male artists represented. Abject art is a tie, and there are more than half as many female performance artists as male ones.

Artworks
--------------------------------------------------------------------------------

There are 

```

Error in eval(expr, envir, enclos) : object 'artwork.title' not found

```

 artworks in the dataset.


```r
summary(artwork[c("artist", "title", "dateText")])
```

```
                            artist                    title      
 Turner, Joseph Mallord William:39389   [title not known]: 3659  
 Jones, George                 : 1046   [blank]          : 3520  
 Moore, Henry, OM, CH          :  623   Blank            : 1995  
 Daniell, William              :  612   [no title]       : 1883  
 Beuys, Joseph                 :  578   Untitled         :  627  
 British (?) School            :  388   Mountains        :  540  
 (Other)                       :26493   (Other)          :56905  
           dateText    
 date not known: 5993  
 1819          : 2908  
 1801          : 1331  
 c.1830–41     : 1194  
 1833          : 1171  
 1831          : 1170  
 (Other)       :55362  
```

```r
summary(artwork$year)
```

```
   Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
   1540    1820    1830    1870    1950    2010    5397 
```


JMW Turner has _tens of thousands_ more works in the collection than the next nearest artist. Is this a glitch? No, it's due to the fact that the Tate holds the [Turner Bequest](http://www.tate.org.uk/research/prints-and-drawings-rooms/turner-bequest) of around 30,000 works on paper.

What are artworks titled? Usually Untitled, or simply no title. "Mountains" appears to be the most popular actual title, although if we stemmed or otherwise abstracted and clustered the titles other popular ones might emerge. 

The most popular years for artworks are in the early 1800s. This, and possibly the titles, are again attributable to Turner. It would probably be productive to remove Turner's works on paper (or more simply just remove all Turner's works) from the dataset and try again, as his presence is clearly skewing the analysis.

Both artists and artworks have movements. Let's look at how artwork movements differ from artists.


```r
summary(artwork.movements)
```

```
   artwork.id    
 Min.   :    22  
 1st Qu.:  6050  
 Median : 11496  
 Mean   : 21962  
 3rd Qu.: 21954  
 Max.   :114918  
                 
                                                  artwork.title 
 [no title]                                              : 674  
 [title not known]                                       : 169  
 Untitled                                                : 116  
 Insertions into Ideological Circuits 2: Banknote Project:  54  
 Walking the Dog                                         :  39  
 Exquisite Corpse                                        :  37  
 (Other)                                                 :5894  
      year                   artwork.medium movement.era.id
 Min.   :1545   Screenprint on paper:1301   Min.   :  8    
 1st Qu.:1920   Oil paint on canvas :1113   1st Qu.:290    
 Median :1963   Lithograph on paper : 527   Median :415    
 Mean   :1936   Etching on paper    : 393   Mean   :327    
 3rd Qu.:1973   Graphite on paper   : 205   3rd Qu.:415    
 Max.   :2009   Bronze              : 113   Max.   :415    
 NA's   :303    (Other)             :3331                  
              movement.era.name  movement.id             movement.name 
 16th and 17th century : 177    Min.   :  293   British Pop     : 846  
 18th century          : 469    1st Qu.:  363   Conceptual Art  : 445  
 19th century          :1004    Median :  433   Pre-Raphaelite  : 405  
 20th century 1900-1945:1156    Mean   : 2421   St Ives School  : 400  
 20th century post-1945:4177    3rd Qu.: 1683   School of London: 373  
                                Max.   :18626   Neo-Classicism  : 310  
                                                (Other)         :4204  
```

```r
summary(artwork.movements$movement.name)[1:20]
```

```
                British Pop              Conceptual Art 
                        846                         445 
             Pre-Raphaelite              St Ives School 
                        405                         400 
           School of London              Neo-Classicism 
                        373                         310 
                    Pop Art Young British Artists (YBA) 
                        246                         226 
          Independent Group              Constructivism 
                        178                         147 
            British War Art                  Minimalism 
                        141                         138 
            Victorian/Genre           Neo-Expressionism 
                        125                         111 
            Neo-Romanticism      Abstract Expressionism 
                        107                         102 
                 Surrealism            Geometry of Fear 
                         96                          84 
            Performance Art          British Surrealism 
                         81                          75 
```

```r
summary(artwork.movements$movement.era.name)
```

```
 16th and 17th century           18th century           19th century 
                   177                    469                   1004 
20th century 1900-1945 20th century post-1945 
                  1156                   4177 
```


Pop and Pre-Raphaelitism gain in popularity, but Conceptualism and Surrealism are still popular.

Subjects
--------------------------------------------------------------------------------

Each artwork is tagged with descriptions of the subjects that it depicts. Subjects have levels, from general to specific, which I've named the category, subcategory and subject. We can group the subjects of artworks by artists and movements to find out what their characteristic subjects were.


```r
summary(artwork.subjects[c("artwork.title", "artwork.dateText", "category.name", 
    "subcategory.name", "subject.name")])
```

```
           artwork.title          artwork.dateText       category.name  
 [title not known]: 13992   date not known: 29732   nature      :76796  
 [no title]       :  8146   1819          : 12948   places      :60314  
 Untitled         :  2148   1833          :  5865   architecture:57507  
 Mountains        :   899   1801          :  5023   people      :52820  
 Shipping         :   462   1831          :  4817   objects     :22990  
 Walking the Dog  :   412   1840          :  4498   society     :20032  
 (Other)          :316957   (Other)       :280133   (Other)     :52557  
                      subcategory.name              subject.name   
 landscape                    : 32722   hill              :  9737  
 adults                       : 22048   wooded            :  8223  
 townscapes, man-made features: 21272   man               :  8164  
 seascapes and coasts         : 12202   figure            :  8118  
 water: inland                : 11839   townscape, distant:  7916  
 countries and continents     : 11704   England           :  7661  
 (Other)                      :231229   (Other)           :293197  
```

```r
summary(artwork.subjects$category.name)[1:20]
```

```
                 abstraction                 architecture 
                       13304                        57507 
emotions, concepts and ideas                      history 
                       11583                         1948 
                   interiors         leisure and pastimes 
                        2467                         3446 
      literature and fiction                       nature 
                        2977                        76796 
                     objects                       people 
                       22990                        52820 
                      places          religion and belief 
                       60314                         4376 
                     society   symbols & personifications 
                       20032                         6242 
        work and occupations                         <NA> 
                        6214                           NA 
                        <NA>                         <NA> 
                          NA                           NA 
                        <NA>                         <NA> 
                          NA                           NA 
```

```r
summary(artwork.subjects$subcategory.name)[1:16]
```

```
                       landscape                           adults 
                           32722                            22048 
   townscapes, man-made features             seascapes and coasts 
                           21272                            12202 
                   water: inland         countries and continents 
                           11839                            11704 
        UK countries and regions cities, towns, villages (non-UK) 
                           10800                            10160 
            non-representational                 transport: water 
                            9583                             9537 
   actions: postures and motions                      UK counties 
                            9055                             8867 
                        features                         military 
                            8694                             7091 
                formal qualities    UK cities, towns and villages 
                            6934                             6695 
```

```r
summary(artwork.subjects$subject.name)[1:20]
```

```
              hill             wooded                man 
              9737               8223               8164 
            figure townscape, distant            England 
              8118               7916               7661 
             river              woman           mountain 
              7549               7303               5932 
            castle             bridge              rocky 
              5298               3769               3759 
             group              coast              Italy 
              3694               3545               3509 
     boat, sailing          townscape             colour 
              3381               3157               2859 
               sea              tower 
              2810               2803 
```


The summary looks like Turner is skewing the results again. The subjects are mostly English landscape of the early 19th Century. But the categories are led by more non-representional subjects, before the subcategories and subjects return to landscape. People ("adults", "man", "woman") emerge as popular subjects as well, indeed they are the second largest subcategory.


```r
summary(artist.subjects[c("artist.name", "category.name", "subcategory.name", 
    "subject.name")])
```

```
                                          artist.name        category.name
 David Lucas                                    :1653   nature      :991  
 Jacques Lipchitz                               : 301   places      :551  
 Colin Lanceley                                 : 181   people      :471  
 Bernard Leach                                  : 104   architecture:345  
 Langlands & Bell (Ben Langlands and Nikki Bell):  78   abstraction :275  
 Linder                                         :  65   objects     :256  
 (Other)                                        :1091   (Other)     :584  
                 subcategory.name    subject.name 
 landscape               : 287    figure   : 157  
 adults                  : 250    England  : 144  
 weather                 : 198    wooded   : 138  
 non-representational    : 186    cloud    :  99  
 UK countries and regions: 151    man      :  84  
 animals: mammals        : 145    geometric:  74  
 (Other)                 :2256    (Other)  :2777  
```

```r
summary(artist.subjects$category.name)[1:20]
```

```
                 abstraction                 architecture 
                         275                          345 
emotions, concepts and ideas                      history 
                         132                           16 
                   interiors         leisure and pastimes 
                          18                           36 
      literature and fiction                       nature 
                          36                          991 
                     objects                       people 
                         256                          471 
                      places          religion and belief 
                         551                           70 
                     society   symbols & personifications 
                         153                           51 
        work and occupations                         <NA> 
                          72                           NA 
                        <NA>                         <NA> 
                          NA                           NA 
                        <NA>                         <NA> 
                          NA                           NA 
```

```r
summary(artist.subjects$subcategory.name)[1:16]
```

```
                    landscape                        adults 
                          287                           250 
                      weather          non-representational 
                          198                           186 
     UK countries and regions              animals: mammals 
                          151                           145 
                  UK counties townscapes, man-made features 
                          129                           118 
UK cities, towns and villages                 water: inland 
                          118                            99 
             formal qualities     from recognisable sources 
                           92                            89 
         seascapes and coasts actions: postures and motions 
                           66                            62 
             transport: water                   residential 
                           57                            49 
```

```r
summary(artist.subjects$subject.name)[1:20]
```

```
       figure       England        wooded         cloud           man 
          157           144           138            99            84 
    geometric         woman       Suffolk          hill        colour 
           74            62            58            52            47 
          cow         river         horse          rain      ceramics 
           40            38            37            35            32 
monochromatic   River Stour         Essex       sunbeam      farmland 
           29            28            27            27            26 
```


The results from artist subjects don't differ appreciably from the artwork ones. We wouldn't expect any difference, but some artworks have more than one artist or have none, so this introduces variations.


```r
summary(movement.subjects[c("movement.name", "era.name", "artwork.title ", "category.name", 
    "subcategory.name", "subject.name")])
```

```
Error: undefined columns selected
```

```r
summary(movement.subjects$category.name)[1:20]
```

```
                 abstraction                 architecture 
                        4977                         2831 
emotions, concepts and ideas                      history 
                        4486                          578 
                   interiors         leisure and pastimes 
                         619                          821 
      literature and fiction                       nature 
                         858                         5634 
                     objects                       people 
                        7516                        11828 
                      places          religion and belief 
                        2635                         1296 
                     society   symbols & personifications 
                        4097                         1843 
        work and occupations                         <NA> 
                        1568                           NA 
                        <NA>                         <NA> 
                          NA                           NA 
                        <NA>                         <NA> 
                          NA                           NA 
```

```r
summary(movement.subjects$subcategory.name)[1:16]
```

```
                          adults             non-representational 
                            4077                             3651 
                formal qualities    actions: postures and motions 
                            2500                             2138 
   clothing and personal effects                     inscriptions 
                            1602                             1402 
       from recognisable sources                             body 
                            1326                             1170 
                       landscape               universal concepts 
                            1161                             1049 
    emotions and human qualities                   social comment 
                             937                              913 
   townscapes, man-made features                      furnishings 
                             898                              868 
reading, writing, printed matter                         features 
                             820                              735 
```

```r
summary(movement.subjects$subject.name)[1:20]
```

```
          woman             man          figure       geometric 
           1854            1649            1197            1191 
         colour    photographic irregular forms     head / face 
           1111             920             563             531 
       standing         England         sitting          female 
            519             503             497             476 
   printed text            text           group        gestural 
            443             428             411             389 
         wooded       landscape        man-made             sea 
            333             305             276             243 
```


"Insertions into Ideological Circuits 2: Banknote Project" has multiple json records with multiple movements and topics in each, so it's over-represented here. The subjects are still similar, although with more photography.

Conclusions
--------------------------------------------------------------------------------

What can we conclude from this? The collection is dominated by male British pop artists, more from England than from Scotland or the rest of the UK. The subjects of artworks are what one would expect: landscape, human figures, abstracts. The Turner Bequest skews some of the data, and this should be accounted for or addressed in analysis. A few other artworks also skew some results.

Next we'll look more closely at artistic movements with some data visualizations.
