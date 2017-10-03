#Jasmin Dial

#exploratory data analysis of DoTs FARS data

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
