library(tidyverse)
library(ggplot2)
library(treemapify)
library(extrafont)
library(sp)
library(rgeos)
library(rgdal)
library(maptools)
library(viridis)
library(foreign)

setwd("/Users/jasmindial/Desktop/dataviz")


maptheme <- theme(axis.title =  element_blank(),
                             axis.text = element_blank(),
                             axis.ticks = element_blank(),
                            panel.grid = element_blank(),
                             plot.title = element_text(size = 13, family = "Impact"),
                             text = element_text(size = 11, family = "Tahoma"), 
                             legend.position = "bottom", legend.title = element_text(family="Tahoma", size=9, face = "bold"),
                             legend.text = element_text(family="Tahoma", size=8.5), plot.caption = element_text(size = 8, face = "italic")) 

#Map 1 - CA counties income share

county_mobility <- read_csv("mobility_by_county.csv", skip = 29)
county_mobility <- county_mobility[1:3142, 1:25]
county_mobility <- county_mobility[-c(1), ]

CA <- filter(county_mobility, State == "California")
CA <- rename(CA, "County" = `County Name`)

county_map <- readOGR(dsn="CA_counties", layer="CA_counties")
#class(counties)

points <- fortify(county_map, region="NAME")
head(points, n=20)

county.df <- left_join(points, CA, by = c("id" = "County")) %>%
  mutate(`Top 1% Income Share` = as.numeric(`Top 1% Income Share`))

county.df2 <- na.omit(county.df)

#create quintiles
#county.df2$top_one_quantile <- cut(county.df2$`Top 1% Income Share`, 
#                                     breaks = c(quantile(county.df2$`Top 1% Income Share`,
#                                                         probs = seq(0, 1, by = 0.20)), na.rm = TRUE), 
#                                     #labels = labels, 
#                                     include.lowest = T)

ggplot(data=county.df2, aes(long, lat, group=group, fill=`Top 1% Income Share`)) + 
  geom_polygon() + scale_fill_viridis(option="magma") + labs(title = "Top 1% Hold Larger Income Share in Bay Area and Southern California",
                                                               subtitle = "Share of Parent Income by County in California",
                                                               caption="The Equality of Opportunity Project", x="", y="",
                                                             fill = "Income Share of Top 1%") +
  coord_equal() +
  maptheme


# Map 2 - wage differences in states
CPS <- read.dta("ggplothw2/morg16.dta", convert.dates = TRUE, convert.factors = TRUE, missing.type = FALSE, 
                         convert.underscore = FALSE, warn.missing.labels = TRUE)

CPS$racecat[CPS$race == 1] <- "White"
CPS$racecat[CPS$race == 2] <- "Black"
CPS$racecat[CPS$race == 4 | race == 5] <- "Asian / Pacific Islander"
CPS$racecat[CPS$race == 3] <- "American Indian"
CPS$racecat[CPS$race %in% c(6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26)] <- "Mixed-race"

CPS2  <- filter(CPS,racecat == "Black" | racecat == "White", ftpt94 == "FT Hours (35+), Usually FT", !is.na(earnwke)) %>%
  mutate(stfips = as.character(stfips))

black <- filter(CPS2, racecat == "Black")
white <- filter(CPS2, racecat == "White")

grouped1 <- group_by(black, stfips)
earnings1 <- summarise(grouped1, black_mean = mean(earnwke))

grouped2 <- group_by(white, stfips)
earnings2 <- summarise(grouped2, white_mean = mean(earnwke))

CPS2 <- left_join(CPS2, earnings1, by = c("stfips"))
CPS2 <- left_join(CPS2, earnings2, by = c("stfips"))
CPS2 <- mutate(CPS2, diff = (white_mean - black_mean) / black_mean)
CPS_map <- CPS2[!duplicated(CPS2$stfips),]

state_map <- readOGR(dsn="states_21basic", layer="states")
#class(state_map)
#state_map@data

points2 <- fortify(state_map, region="STATE_ABBR")
head(points2, n=20)

#county.df <- merge(points, CA, by.x="id", bstay.y="`County Name`")
state.df <- left_join(points2, CPS_map, by = c("id" = "stfips"))

ggplot(data=state.df, aes(long, lat, group=group, fill=diff)) + 
  geom_polygon() + geom_path(color="white", size = 0.2) +
  scale_fill_viridis(option="magma") + labs(title = "Income Gap between Black and White Workers Varies by State",
                                                             subtitle = "Weekly Earnings for Full-Time Workers",
                                                             caption="2016 CPS Merged Outgoing Rotation Group", fill = "% Difference in Earnings") +
  coord_equal() +
  maptheme
