## 3. Data Processing
I have used R for analysing the data with RStudio Desktop.

The R code I've used is included in the repository and can be reached via the link below:

[Fitbase_Data.R](Fitbase_Data.R)

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
sum(duplicated(daily_activity)) #0
sum(is.na(daily_activity$TotalSteps)) #0

sum(duplicated(daily_sleep)) #3
sum(is.na(daily_sleep$TotalMinutesAsleep)) #0
daily_sleep <- daily_sleep %>% distinct()

sum(duplicated(hourly_calories)) #0
sum(is.na(hourly_calories$Calories)) #0

sum(duplicated(hourly_intensities)) #0
sum(is.na(hourly_intensities$TotalIntensity)) #0

sum(duplicated(hourly_steps)) #0
sum(is.na(hourly_steps$StepTotal)) #0

sum(duplicated(weight_log)) #0
sum(is.na(weight_log$WeightKg)) #0
```














