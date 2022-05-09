install.packages("tidyverse")
install.packages("janitor")
library(tidyverse)
library(janitor)
library(lubridate)
library(scales)

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
  labs(title = "Activity Tracker Usage by User", 
       x = "# of days", y = "# of Users",
       caption = "Data Source: FitBit Fitness Tracker Data, Möbius")
ggsave("Plot_ActivityTrackerUsage.png", width = 5, height = 4)

# User engagement of sleep tracker
d_sleep_tracker_usage <- sleep_activity %>% 
  group_by(id) %>% 
  summarise(n = n()) %>% 
  arrange(by = n)

ggplot(d_sleep_tracker_usage) + 
  aes(x=n) +
  geom_histogram(binwidth = 1) +
  geom_vline(xintercept = median(d_sleep_tracker_usage$n), color="#D8315B") +
  geom_vline(xintercept = mean(d_sleep_tracker_usage$n), color="#DF9B6D") +
  geom_label(aes(x=median(n)-3, y=2.9, label = "median"), color="#D8315B") +
  geom_label(aes(x=median(n)-2.4, y=2.7, label = median(n)), color="#D8315B") +
  geom_label(aes(x=mean(n)-2.5, y=2.4, label = "mean"), color="#DF9B6D") +
  geom_label(aes(x=mean(n)-2, y=2.2, label = round(mean(n))), color="#DF9B6D") +
  labs(title = "Sleep Tracker Usage by User", 
       x = "# of days", y = "# of Users",
       caption = "Data Source: FitBit Fitness Tracker Data, Möbius")
ggsave("Plot_SleepTrackerUsage.png", width = 5, height = 4)

# User engagement of weight tracker
d_weight_tracker_usage <- weight_log %>% 
  group_by(id) %>% 
  summarise(n = n()) %>% 
  arrange(by = n)

# ggplot(d_weight_tracker_usage) + 
#   aes(x=n) +
#   geom_histogram(binwidth = 1) +
#   geom_vline(xintercept = median(d_weight_tracker_usage$n), color="#818AA3") +
#   geom_vline(xintercept = mean(d_weight_tracker_usage$n), color="#A491D3") +
#   geom_label(aes(x=median(n)+3, y=2.9, label = "median"), color="#818AA3") +
#   geom_label(aes(x=median(n)+2.4, y=2.7, label = median(n)), color="#818AA3") +
#   geom_label(aes(x=mean(n)+2.5, y=2.4, label = "mean"), color="#A491D3") +
#   geom_label(aes(x=mean(n)+2, y=2.2, label = round(mean(n))), color="#A491D3") +
#   labs(title = "Weight Tracker Usage by User", x = "# of days", y = "# of Users")

m_weight_tracker_usage <- weight_log %>% 
  group_by(day_month) %>% 
  summarise(n=n())
ggplot(m_weight_tracker_usage) +
  aes(x=day_month, y=n) +
  geom_col() +
  labs(title = "Weight Tracker Usage by Day_Month", 
       x = "Day", y = "# of Users",
       caption = "Data Source: FitBit Fitness Tracker Data, Möbius")
ggsave("Plot_WeightTrackerUsage_byDayMonth.png", width = 5, height = 4)

w_weight_tracker_usage <- weight_log %>% 
  group_by(day_week) %>% 
  summarise(n = n()) %>% 
  arrange(day_week)
ggplot(w_weight_tracker_usage) + 
  aes(x=day_week, y=n) + 
  geom_col() +
  labs(title = "Weight Tracker Usage by Day_Week", 
       subtitle = "1:Monday - 7:Sunday",
       x = "Day", y = "# of Users",
       caption = "Data Source: FitBit Fitness Tracker Data, Möbius")
ggsave("Plot_WeightTrackerUsage_byDayWeek.png", width = 5, height = 4)

# Cross function usage
joined_table <- daily_activity %>% 
  select(id, date, total_steps, calories) %>% 
  full_join(daily_sleep %>% select(id, date, total_minutes_asleep), by = c("id", "date")) %>% 
  full_join(weight_log %>% select(id, date, weight_kg), by = c("id", "date"))
n_distinct(joined_table$id)

joined_table %>% filter(is.na(joined_table$total_steps)) #all users used activity tracker

joined_by_user <- joined_table %>% 
  replace(is.na(joined_table), 0) %>% 
  group_by(id) %>% 
  summarise(sum_steps = sum(total_steps),
            sum_sleep = sum(total_minutes_asleep),
            max_weight = max(weight_kg)) # so that we can know that user has recorded weight at least once

joined_by_user %>% 
  filter(sum_steps > 0) %>% 
  summarise(n())
# all 33 users have used the activity tracker

all_function_user <- joined_by_user %>% 
  filter(sum_sleep > 0, max_weight > 0)
all_count <- all_function_user %>% summarise(n())
# 6 users used all functions at least once

activity_sleep_user <- joined_by_user %>% 
  filter(sum_sleep > 0, max_weight == 0)
act_slp_count <- activity_sleep_user %>% summarise(n())
# 18 users used activity and sleep trackers at least once, but never used the weight log

activity_weight_user <- joined_by_user %>% 
  filter(sum_sleep == 0, max_weight > 0)
act_wth_count <- activity_weight_user %>% summarise(n())
# 2 users used activity and sleep trackers at least once, but never used the weight log

only_activity_user <- joined_by_user %>% 
  filter(sum_sleep == 0, max_weight == 0)
act_count <- only_activity_user %>% summarise(n())
# 7 users used only activity tracker

df <- all_count %>% full_join(act_slp_count) %>% full_join(act_wth_count) %>% full_join(act_count) %>%
  mutate(type = c("all functions","activity & sleep", "activity & weight","only activity")) %>% 
  rename(count = `n()`) %>% 
  mutate(percentage = percent(count/sum(count), accuracy = 1)) %>% 
  arrange(desc(type))

tibble(df) %>% 
  select(type, count, percentage) %>% 
  arrange(desc(count))

ggplot(df) + 
  aes(x="", y= count, fill=type) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) +
  theme_void() +
  geom_text(aes(y = count/2 + c(0, cumsum(count)[-length(count)]), 
                label = percentage), size=6, color="white") +
  labs(title ="Percentage of Users - Cross Function Usage",
       caption = "Data Source: FitBit Fitness Tracker Data, Möbius")
ggsave("Plot_PercentageUsersCrossFunction.png", width = 5, height = 4)

# Segmentation
#Scenario 1
segmentation_user <- joined_table %>% 
  group_by(id) %>% 
  summarise(
    day_steps = sum(!is.na(total_steps)),
    day_sleep = sum(!is.na(total_minutes_asleep)),
    day_weight = sum(!is.na(weight_kg))
            ) %>% 
    mutate(segmentation_user, segment = 
         ifelse(day_steps == 31 & day_sleep > median(day_sleep) & day_weight > 0, "1. Golden user",
                ifelse(day_steps > median(day_steps) & day_sleep > mean(day_sleep), "2. Silver user",
                       ifelse(day_steps > mean(day_steps), "3. Bronz user", "4. Other"))))

segmentation_numbers <- tibble(segmentation_user) %>% 
  group_by(segment) %>% 
  summarise(number = n()) %>% 
  arrange(segment)

ggplot(segmentation_numbers) +
  aes(x = segment, y = number, fill = number) +
  geom_bar(stat = "identity") +
  theme(legend.position = "none") +
  labs(title = "Scenario 1", x = "User group", y = "# of users",
       caption = "Data Source: FitBit Fitness Tracker Data, Möbius")
ggsave("Plot_Segmentation.png", width = 5, height = 4)

#Scenario 2
segmentation_user_2 <- joined_table %>% 
  group_by(id) %>% 
  summarise(
    day_steps = sum(!is.na(total_steps)),
    day_sleep = sum(!is.na(total_minutes_asleep)),
  ) %>% 
  mutate(segmentation_user, segment = 
           ifelse(day_steps == 31 & day_sleep > median(day_sleep), "1. Golden user",
                  ifelse(day_steps > median(day_steps) & day_sleep > mean(day_sleep), "2. Silver user",
                         ifelse(day_steps > mean(day_steps), "3. Bronz user", "4. Other"))))

segmentation_numbers_2 <- tibble(segmentation_user_2) %>% 
  group_by(segment) %>% 
  summarise(number = n()) %>% 
  arrange(segment)

ggplot(segmentation_numbers_2) +
  aes(x = segment, y = number, fill = number) +
  geom_bar(stat = "identity") +
  theme(legend.position = "none") +
  labs(title = "Scenario 2", x = "User group", y = "# of users",
       caption = "Data Source: FitBit Fitness Tracker Data, Möbius")
ggsave("Plot_Segmentation_2.png", width = 5, height = 4)

#Scenario 3
segmentation_user_3 <- joined_table %>% 
  group_by(id) %>% 
  summarise(
    day_steps = sum(!is.na(total_steps)),
    day_sleep = sum(!is.na(total_minutes_asleep)),
  ) %>% 
  mutate(segmentation_user, segment = 
           ifelse(day_steps == 31 & day_sleep == 31, "1. Golden user",
                  ifelse(day_steps > mean(day_steps) & day_sleep > mean(day_sleep), "2. Silver user",
                         ifelse(day_steps > mean(day_steps), "3. Bronz user", "4. Other"))))

segmentation_numbers_3 <- tibble(segmentation_user_3) %>% 
  group_by(segment) %>% 
  summarise(number = n()) %>% 
  arrange(segment)

ggplot(segmentation_numbers_3) +
  aes(x = segment, y = number, fill = number) +
  geom_bar(stat = "identity") +
  theme(legend.position = "none") +
  labs(title = "Scenario 3", x = "User group", y = "# of users",
       caption = "Data Source: FitBit Fitness Tracker Data, Möbius")
ggsave("Plot_Segmentation_3.png", width = 5, height = 4)

