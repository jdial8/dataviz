# Jasmin Dial

# exploratory data analysis of DoTs FARS data

library(readr)
library(haven)
library(dplyr)
library(tidyr)
library(stringr)
library(ggplot2)

acc2014 <- read_sas("accident.sas7bdat")
acc2015 <- read_csv("accident.csv")

class(acc2014)
class(acc2015)

acc2014 <- mutate(acc2014, TWAY_ID2 = na_if(TWAY_ID2, ""))
table(is.na(acc2014$TWAY_ID2))

dim(acc2014)
dim(acc2015)

colnames(acc2014) %in% colnames(acc2015)
colnames(acc2014)[19]
# "ROAD_FNC" is not in acc2015

colnames(acc2015) %in% colnames(acc2014)
colnames(acc2015)[19:21]
# "RUR_URB", "FUNC_SYS", and "RD_OWNER" are not in acc2014

#combine two years 
acc <- bind_rows(acc2014, acc2015)
count(acc, RUR_URB)
# There are 30056 NA values for RUR_URB because acc2014 did not contain RUR_URB 

fips <- read_csv("fips.csv")
glimpse(fips)

acc <- mutate(acc, STATE = as.character(STATE), COUNTY = as.character(COUNTY))

acc$STATE <- str_pad(acc$STATE, 2, side="left", pad = "0")
acc$COUNTY <- str_pad(acc$COUNTY, 3, side="left", pad = "0")

acc <- rename(acc, "StateFIPSCode" = "STATE", "CountyFIPSCode" = "COUNTY")

#add FIPS data 
acc <- left_join(acc, fips, by = c("StateFIPSCode", "CountyFIPSCode"))

#calculate total fatalities for each state and year
grouped <- group_by(acc, YEAR, StateName)
agg <- summarize(grouped, TOTAL = sum(FATALS))

#calculate changes from 2014-2015 and keep those with at least 15% increase
agg_wide <- spread(agg, key = YEAR, value = TOTAL)
agg_wide <- rename(agg_wide, "FATALS14" = "2014", "FATALS15" = "2015")
agg_wide <- mutate(agg_wide, percent_change = (FATALS15 - FATALS14) / FATALS14)
agg_wide <- arrange(agg_wide, desc(percent_change))
agg_wide <- filter(agg_wide, percent_change > .15 & !is.na(StateName))

#combine last seven commands using piping
agg <- acc %>%
        group_by(YEAR, StateName) %>%
        summarize(TOTAL = sum(FATALS)) %>%
        spread(key = YEAR, value = TOTAL) %>%
        rename("FATALS14" = "2014", "FATALS15" = "2015") %>%
        mutate(percent_change = (FATALS15 - FATALS14) / FATALS14) %>%
        arrange(desc(percent_change)) %>%
        filter(percent_change > 0.15 & !is.na(StateName))
               
glimpse(agg)
        
               
