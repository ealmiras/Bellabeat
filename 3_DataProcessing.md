## 3. Data Processing
I've used R for analysing the data with RStudio Desktop. You can reach my R code in the directory, also by clicking [here](Fitbit_Data.R)!

I decided to use daily activity, sleep, and weight_log data & hourly calories, intensities, and steps datasets in my analysis.

```
daily_activity <- read_csv(".../dailyActivity_merged.csv")
hourly_calories <- read_csv(".../hourlyCalories_merged.csv")
hourly_intensities <- read_csv(".../hourlyIntensities_merged.csv")
hourly_steps <- read_csv(".../hourlySteps_merged.csv")
daily_sleep <- read_csv(".../sleepDay_merged.csv")
weight_log <- read_csv(".../weightLogInfo_merged.csv")
```

### 3.1. Data Cleaning
As a first step, I checked the datasets with the **head()** function and realised that the date columns are shown as **char**

```
head(daily_activity) #date - char
head(hourly_calories) #datetime - char
head(hourly_intensities) #datetime - char
head(hourly_steps) #datetime - char
head(daily_sleep) #datetime - char
head(weight_log) #datetime - char
```

For the sleep data I used only the date format as the time information on data were 12AM for all entries.
Also, for the weight data I used only the date format as the time information is irrelevant for this metric.

```
daily_activity$ActivityDate <- as.Date(daily_activity$ActivityDate, format ="%m/%d/%Y")
hourly_calories$ActivityHour <- strptime (hourly_calories$ActivityHour, format = "%m/%d/%Y %I:%M:%S %p")
hourly_intensities$ActivityHour <- strptime (hourly_intensities$ActivityHour, format = "%m/%d/%Y %I:%M:%S %p")
hourly_steps$ActivityHour <- strptime (hourly_steps$ActivityHour, format = "%m/%d/%Y %I:%M:%S %p")
daily_sleep$SleepDay <- as.Date(daily_sleep$SleepDay, format = "%m/%d/%Y %I:%M:%S %p")
weight_log$Date <- as.Date(weight_log$Date, format = "%m/%d/%Y %I:%M:%S %p")
```

Next step, I checked the data for **zero step** and **zero intensitisy** entries in the activity logs. Zero-steps means that the fitbit has not been used in that time frame, so I excluded that entries from the data.

```
daily_activity %>% filter(TotalSteps == 0) # 77 entries among 940 have Total Step value of 0
daily_activity <- daily_activity %>% filter(TotalSteps != 0)

hourly_intensities %>% filter(TotalIntensity == 0) #9.087 entries among 22.099 have Total Intensity value of 0
hourly_intensities <- hourly_intensities %>% filter(TotalIntensity != 0)

hourly_steps %>% filter(StepTotal == 0) # 9287 entries among 22.098 have Total Step value of 0
hourly_steps <- hourly_steps %>% filter(StepTotal != 0)
```

Then, I checked for the duplicates and N/A values for the key parameters in the dataset and removed **3** duplicates from the **daily_sleep** table

```
c(sum(duplicated(daily_activity)), sum(is.na(daily_activity$TotalSteps))) #0-0
c(sum(duplicated(daily_sleep)), sum(is.na(daily_sleep$TotalMinutesAsleep))) #3-0
c(sum(duplicated(hourly_calories)), sum(is.na(hourly_calories$Calories))) #0-0
c(sum(duplicated(hourly_intensities)), sum(is.na(hourly_intensities$TotalIntensity))) #0-0
c(sum(duplicated(hourly_steps)), sum(is.na(hourly_steps$StepTotal))) #0-0
c(sum(duplicated(weight_log)), sum(is.na(weight_log$WeightKg))) #0-0

daily_sleep <- daily_sleep %>% distinct()
```

To make analysis easier, I cleaned the column names and at the same gave date columns a common name to make it easier to join them in the next stages.

```
daily_activity <- daily_activity %>% clean_names() %>% rename(date = activity_date)
daily_sleep <- daily_sleep %>% clean_names() %>% rename(date = sleep_day)
hourly_calories <- hourly_calories %>% clean_names() %>% rename(date = activity_hour)
hourly_intensities <- hourly_intensities %>% clean_names() %>% rename(date = activity_hour)
hourly_steps <- hourly_steps %>% clean_names() %>% rename(date = activity_hour)
weight_log <- weight_log %>% clean_names()
```

## 3.2. Joining Tables
To be able to cross analyse the data, I merged some tables:
- Daily activity table and sleep table
- Hourly activity tables
While joining the tables, I also added weekday information to the both tables.
I added the weekday information also to the weight table and daily activity table.

```
sleep_activity <- daily_sleep %>% 
  left_join(daily_activity, by = c("id", "date")) %>% mutate(day_week = weekdays(date))
sum(is.na(sleep_activity$total_steps)) #checking if any entry from the sleep data is mising step information - 0 

hourly_activity <- hourly_calories %>% 
  full_join(hourly_intensities, by = c("id", "date")) %>% full_join(hourly_steps, by = c("id", "date")) %>% mutate(day_week = weekdays(date))
  
weight_log <- weight_log %>% 
  mutate(day_week = weekdays(date))

daily_activity <- daily_activity %>% 
  mutate(day_week = weekdays((date)))
```

At the end of the preparation phase, I had 3 main tables to use in my analysis.
- Daily Activity
- Hourly Activity
- Sleep Activity
