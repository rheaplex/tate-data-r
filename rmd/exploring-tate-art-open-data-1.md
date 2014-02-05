Exploring Tate Art Open Data 1
================================================================================




This is the first in a series of posts examining Tate's excellent collection dataset available at [http://www.tate.org.uk/about/our-work/digital/collection-data](http://www.tate.org.uk/about/our-work/digital/collection-data) .

I've processed that dataset using code for Mongo DB and Node.js available at [https://gitorious.org/robmyers/tate-data/](https://gitorious.org/robmyers/tate-data/) .

The R and R Markdown code for this series is available at [https://gitorious.org/robmyers/tate-data-r/](https://gitorious.org/robmyers/tate-data-r/) .

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


That's quite a different result from that suggested by the yearly results. Decade-wise, birth percentiles are clustered around the turn of the 20th century, deaths around the second world war. But the largest number of births are in the 1930s/1940s with the 1960s coming in second. DEATHS XXXXXX.

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

The data for artists includes information on 135 artists movements. If we looked at the artwork data there might be more, but we'll stick with the artists for now. 


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

There are 16 artworks in the dataset.











