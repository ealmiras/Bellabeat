install.packages("tidyverse")
install.packages("janitor")
library(tidyverse)
library(janitor)

# Loading the data --------------------------------------------------------
daily_activity <- read_csv("/Users/asozlu/Desktop/Google Data Analytics/Fitabase_Data/dailyActivity_merged.csv")
hourly_calories <- read_csv("/Users/asozlu/Desktop/Google Data Analytics/Fitabase_Data/hourlyCalories_merged.csv")
hourly_intensities <- read_csv("/Users/asozlu/Desktop/Google Data Analytics/Fitabase_Data/hourlyIntensities_merged.csv")
hourly_steps <- read_csv("/Users/asozlu/Desktop/Google Data Analytics/Fitabase_Data/hourlySteps_merged.csv")
daily_sleep <- read_csv("/Users/asozlu/Desktop/Google Data Analytics/Fitabase_Data/sleepDay_merged.csv")
weight_log <- read_csv("/Users/asozlu/Desktop/Google Data Analytics/Fitabase_Data/weightLogInfo_merged.csv")

# Number of unique users
n_distinct(daily_activity$Id) #33
n_distinct(hourly_calories$Id) #33
n_distinct(hourly_intensities$Id) #33
n_distinct(hourly_steps$Id) #33
n_distinct(daily_sleep$Id) #24
n_distinct(weight_log$Id) #8 

# Data cleaning -----------------------------------------------------------
head(daily_activity) #date - char
head(hourly_calories) #datetime - char
head(hourly_intensities) #datetime - char
head(hourly_steps) #datetime - char
head(daily_sleep) #datetime - char
head(weight_log) #datetime - char

# Correction of date formats
daily_activity <- daily_activity
daily_activity$ActivityDate <- as.Date(daily_activit$ActivityDate, format ="%m/%d/%Y")
hourly_calories$ActivityHour <- strptime (hourly_calories$ActivityHour, format = "%m/%d/%Y %I:%M:%S %p")
hourly_intensities$ActivityHour <- strptime (hourly_intensities$ActivityHour, format = "%m/%d/%Y %I:%M:%S %p")
hourly_steps$ActivityHour <- strptime (hourly_steps$ActivityHour, format = "%m/%d/%Y %I:%M:%S %p")
daily_sleep$SleepDay <- as.Date(daily_sleep$SleepDay, format = "%m/%d/%Y %I:%M:%S %p")
weight_log$Date <- as.Date(weight_log$Date, format = "%m/%d/%Y %I:%M:%S %p")

# Zero steps or zero intensities means fitbit was not used
daily_activity %>% filter(TotalSteps == 0) # 77 entries among 940 have Total Step value of 0
daily_activity <- daily_activity %>% filter(TotalSteps != 0)

hourly_intensities %>% filter(TotalIntensity == 0) #9.087 entries among 22.099 have Total Intensity value of 0
hourly_intensities <- hourly_intensities %>% filter(TotalIntensity != 0)

hourly_steps %>% filter(StepTotal == 0) # 9287 entries among 22.098 have Total Step value of 0
hourly_steps <- hourly_steps %>% filter(StepTotal != 0)

# Controlling and removing duplicates and N/A values for the key metrics
c(sum(duplicated(daily_activity)), sum(is.na(daily_activity$TotalSteps))) #0-0
c(sum(duplicated(daily_sleep)), sum(is.na(daily_sleep$TotalMinutesAsleep))) #3-0
c(sum(duplicated(hourly_calories)), sum(is.na(hourly_calories$Calories))) #0-0
c(sum(duplicated(hourly_intensities)), sum(is.na(hourly_intensities$TotalIntensity))) #0-0
c(sum(duplicated(hourly_steps)), sum(is.na(hourly_steps$StepTotal))) #0-0
c(sum(duplicated(weight_log)), sum(is.na(weight_log$WeightKg))) #0-0

daily_sleep <- daily_sleep %>% distinct()

# Cleaning column names and matching all date-column names for the next steps
daily_activity <- daily_activity %>% 
  clean_names() %>% 
  rename(date = activity_date)
daily_sleep <- daily_sleep %>% 
  clean_names() %>% 
  rename(date = sleep_day)
hourly_calories <- hourly_calories %>% 
  clean_names() %>% 
  rename(date = activity_hour)
hourly_intensities <- hourly_intensities %>% 
  clean_names() %>% 
  rename(date = activity_hour)
hourly_steps <- hourly_steps %>% 
  clean_names() %>% 
  rename(date = activity_hour)
weight_log <- weight_log %>% 
  clean_names()



