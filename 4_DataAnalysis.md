## 4. Data Analysis

### 4.1. User Engagement
To begin with, I decided to first analyse the user engagement.
I used histogram charts to and median values.

We can see that there's a high level user engagement for the Activity and Sleep trackers.
Especially for the activity tracker, the median of the usage is 30 days out of 31 days in total for the period.

<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_ActivityTrackerUsage.png" width="450" /> |
<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_SleepTrackerUsage.png" width="450" />

For the weight tracker data, as there are a pretty limited number of users, statistical analysis would mislead.
Due to the nature of the data, it is expected that the users log their data less frequently, probable that less frequent than once a month.
To be able to statistically comment on the user engagement, it is recommended to analyse a bigger dataset.

However, for the sake of curiosity, I checked the data to see if there's any pattern regarding the common days/periods users log their weight on app.
As we have the data of only one month, it's hard to see a pattern.
For the weekly data, we can say that it's more probable of the users to log their weight data in the first half of the week, and the least probable on Friday and Saturdays.

<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_WeightTrackerUsage_byDayMonth.png" width="450" /> |
<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_WeightTrackerUsage_byDayWeek.png" width="450" />

#### Foundings
- User engagement is the highest for the activity tracker and has a very high median for days used
- Sleep tracker follows the activity tracker, also has a high median for days used
- Even though it is hard to comment on the user engagement for the weight log, it can be said that there's a pattern about which day of the week users log data in general

### 4.2. Cross Function Usage
Next, I wanted to check the distribution of the user who use more than one function of the app.

Firstly, it's important to mention that, for this analysis, the different trackers have accepted as "used" even if the usage was only one day.

Secondly, it's observed that, all 33 users analysed have used activity tracker.
- 7 of those have used only the activity tracker
- 18 have used the sleep tracker together with the activity tracker
- 2 have used weight log together with the activity tracker
- 6 have used all functions analysed (activity, sleep, weight log)

<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_PercentageUsersCrossFunction.png" width="450" /> 

#### Foundings
- Users generally use the activity tracker and the sleep tracker together
- The user valuation of the functions may be ordered as Activity tracker -> Sleep tracker -> Weight log
- Meaning that, users primarily uses the app for the activity tracker, then some of those adds the sleep tracker to their app journey, finally some of those who are using these both functions adds the weight log to their journey

### 4.3. User Segmentation
Folowing the previous analysis, I wanted to look at the usage frequency and create a segmentation.

For this purpose, I've studied a few different scenarios to find the best fit.

<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_Segmentation.png" width="230" /> |
<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_Segmentation_2.png" width="230" /> |
<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_Segmentation_3.png" width="230" /> |
<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_Segmentation_4.png" width="230" /> 

The scenario I've choosed is the 4th one and the criteria are as follows:
- 1: Activity tracker (31 days), Sleep tracker (31 days)
- 2: Activity tracker (> median), Sleep tracker (> median)
- 3: Activity tracker (> mean), Sleep tracker (> mean)
- 4: Activity tracker (> mean)
- 5: Other

<img src="https://github.com/ealmiras/Bellabeat/blob/main/Plot_UserSegmentation.png" width="450" /> 

#### Foundings
- 36% of the users are considered in the "Other" group, that are using both the activity tracker and the sleep tracker below the average number of days, which can be considered normal
- However when identified separately, 63% of the users are below the average number of days for the sleep tracker.

**This result shows that there is an availability to improve the use frequency of the Sleep Tracker**


