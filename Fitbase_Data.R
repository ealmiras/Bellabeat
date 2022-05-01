install.packages("tidyverse")
install.packages("janitor")
library(tidyverse)
library(janitor)

# Loading the data -----
daily_activity <- read_csv(".../Google Data Analytics/Fitabase_Data/dailyActivity_merged.csv")
heart_rate <- read_csv(".../Google Data Analytics/Fitabase_Data/heartrate_seconds_merged.csv")
hourly_calories <- read_csv(".../Google Data Analytics/Fitabase_Data/hourlyCalories_merged.csv")
hourly_intensities <- read_csv(".../Desktop/Google Data Analytics/Fitabase_Data/hourlyIntensities_merged.csv")
hourly_steps <- read_csv(".../Google Data Analytics/Fitabase_Data/hourlySteps_merged.csv")
daily_sleep <- read_csv(".../Google Data Analytics/Fitabase_Data/sleepDay_merged.csv")
weight_log <- read_csv(".../Google Data Analytics/Fitabase_Data/weightLogInfo_merged.csv")

head(daily_activity) #date - char
head(heart_rate) #datetime - char
head(hourly_calories) #datetime - char
head(hourly_intensities) #datetime - char
head(hourly_steps) #datetime - char
head(daily_sleep) #datetime - char
head(weight_log) #datetime - char

# Number of unique users ----
n_distinct(daily_activity$Id) #33
n_distinct(heart_rate$Id) #14
n_distinct(hourly_calories$Id) #33
n_distinct(hourly_intensities$Id) #33
n_distinct(hourly_steps$Id) #33
n_distinct(daily_sleep$Id) #24
n_distinct(weight_log$Id) #8 


