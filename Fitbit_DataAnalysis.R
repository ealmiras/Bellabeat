install.packages("tidyverse")
install.packages("janitor")
library(tidyverse)
library(janitor)
library(lubridate)

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
daily_activity$ActivityDate <- as.Date(daily_activity$ActivityDate, format ="%m/%d/%Y")
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
  clean_names() %>% rename(date = activity_date)
daily_sleep <- daily_sleep %>% 
  clean_names() %>% rename(date = sleep_day)
hourly_calories <- hourly_calories %>% 
  clean_names() %>% rename(date = activity_hour)
hourly_intensities <- hourly_intensities %>% 
  clean_names() %>% rename(date = activity_hour)
hourly_steps <- hourly_steps %>% 
  clean_names() %>% rename(date = activity_hour)
weight_log <- weight_log %>% 
  clean_names()

# Joining the tables 
sleep_activity <- daily_sleep %>% 
  left_join(daily_activity, by = c("id", "date")) %>% 
  mutate(day_week = wday(ymd(date), week_start = 1))
sum(is.na(sleep_activity$total_steps))

hourly_activity <- hourly_calories %>% 
  full_join(hourly_intensities, by = c("id", "date")) %>% 
  full_join(hourly_steps, by = c("id", "date")) %>% 
  mutate(day_week = wday(ymd_hms(date), week_start = 1))

weight_log <- weight_log %>% 
  mutate(day_week = wday(ymd(date), week_start = 1)) %>% 
  mutate(day_month = as.numeric(format(date, format = "%d")))

daily_activity <- daily_activity %>% 
  mutate(day_week = wday(ymd(date), week_start = 1))

# Data Analysis -----------------------------------------------------------
# User engagement of activity tracker
d_act_tracker_usage <- daily_activity %>% 
  group_by(id) %>% 
  summarise(n = n()) %>% 
  arrange(by = n)

ggplot(d_act_tracker_usage) + 
  aes(x=n) +
  geom_histogram(binwidth = 1) +
  geom_vline(xintercept = median(d_act_tracker_usage$n), color="#D8315B") +
  geom_vline(xintercept = mean(d_act_tracker_usage$n), color="#DF9B6D") +
  geom_label(aes(x=median(n)-3, y=15, label = "median"), color="#D8315B") +
  geom_label(aes(x=median(n)-2, y=14, label = median(n)), color="#D8315B") +
  geom_label(aes(x=mean(n)-2.5, y=10, label = "mean"), color="#DF9B6D") +
  geom_label(aes(x=mean(n)-2, y=9, label = round(mean(n))), color="#DF9B6D") +
  labs(title = "Activity Tracker Usage by User", x = "# of days", y = "# of Users")

# User engagement of sleep tracker
d_sleep_tracker_usage <- sleep_activity %>% 
  group_by(id) %>% 
  summarise(n = n()) %>% 
  arrange(by = n)

ggplot(d_sleep_tracker_usage) + 
  aes(x=n) +
  geom_histogram(binwidth = 1) +
  geom_vline(xintercept = median(d_sleep_tracker_usage$n), color="#0A2463") +
  geom_vline(xintercept = mean(d_sleep_tracker_usage$n), color="#8D99AE") +
  geom_label(aes(x=median(n)-3, y=2.9, label = "median"), color="#0A2463") +
  geom_label(aes(x=median(n)-2.4, y=2.7, label = median(n)), color="#0A2463") +
  geom_label(aes(x=mean(n)-2.5, y=2.4, label = "mean"), color="#8D99AE") +
  geom_label(aes(x=mean(n)-2, y=2.2, label = round(mean(n))), color="#8D99AE") +
  labs(title = "Sleep Tracker Usage by User", x = "# of days", y = "# of Users")

# User engagement of weight tracker
d_weight_tracker_usage <- weight_log %>% 
  group_by(id) %>% 
  summarise(n = n()) %>% 
  arrange(by = n)

ggplot(d_weight_tracker_usage) + 
  aes(x=n) +
  geom_histogram(binwidth = 1) +
  geom_vline(xintercept = median(d_weight_tracker_usage$n), color="#818AA3") +
  geom_vline(xintercept = mean(d_weight_tracker_usage$n), color="#A491D3") +
  geom_label(aes(x=median(n)+3, y=2.9, label = "median"), color="#818AA3") +
  geom_label(aes(x=median(n)+2.4, y=2.7, label = median(n)), color="#818AA3") +
  geom_label(aes(x=mean(n)+2.5, y=2.4, label = "mean"), color="#A491D3") +
  geom_label(aes(x=mean(n)+2, y=2.2, label = round(mean(n))), color="#A491D3") +
  labs(title = "Weight Tracker Usage by User", x = "# of days", y = "# of Users")

m_weight_tracker_usage <- weight_log %>% 
  group_by(day_month) %>% 
  summarise(n=n())
ggplot(m_weight_tracker_usage) +
  aes(x=day_month, y=n) +
  geom_col() +
  labs(title = "Weight Tracker Usage by Day_Month", 
       x = "Day", y = "# of Users")

w_weight_tracker_usage <- weight_log %>% 
  group_by(day_week) %>% 
  summarise(n = n()) %>% 
  arrange(day_week)
ggplot(w_weight_tracker_usage) + 
  aes(x=day_week, y=n) + 
  geom_col() +
  labs(title = "Weight Tracker Usage by Day_Week", 
       subtitle = "1:Monday - 7:Sunday",
       x = "Day", y = "# of Users")
