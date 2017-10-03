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

acc <- bind_rows(acc2014, acc2015)
count(add, RUR_URB)
# There are 30056 NA values for RUR_URB because acc2014 did not contain RUR_URB 

