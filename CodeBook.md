CODE BOOK

Author: Eric Bollinger [ewillyb@gmail.com]

Raw data are located here:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Note that my run_analysis.R script requires that the raw data files be downloaded locally.

The raw data zip file contains code book variable description information, which I will not be replicating here.

Description of Final Dataset
Name: tidy_means

Contains 40 observations of 88 variables.

Rows/observations are uniquely identified by "subject_id" and "activity".
- subject_id is an identifier for the subject. There are 30 subjects and they are not identified by anything other than id.
- activity is the label of the activity performed by the subject. activity is one of these six values: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING. These values and their ids can be found in the activity_labels.txt source file.

For each unique combination of subject_id and activity, the means of 86 variables are computed. These variables represent a subset of the features listed in the features.txt source file. Specifically, they represent only the mean or standard deviation statistics of the raw data measurements. The raw data measurements come from a union of data from the X_train.txt and X_test.txt source files. The original code book and accompanying website describe the features/variables. I will not replicate the descriptions in this code book.


RECIPE: From Raw Data Files to tidy_means Dataset

1. Read in the subject training data and store in subject_train_df data frame. Name the variables appropriately.

subject_train_df <- read.delim2("./UCI HAR Dataset/train/subject_train.txt", header=F, col.names = c("subject_id"))

2. Read in the subject test data and store in subject_test_df data frame. Name the variables appropriately.

subject_test_df <- read.delim2("./UCI HAR Dataset/test/subject_test.txt", header=F, col.names = c("subject_id"))

3. Read in the features lookup data and store in features_df data frame. Name the variables appropriately. 

features_df <- read.table("./UCI HAR Dataset/features.txt", header=F, col.names = c("feature_id", "feature"))

4. Read in the training data and store in x_train_df data frame. Set the column names to the feature values in the features_df data frame. Note that the features as listed by row in features.txt correspond by position to the data measurements captured by column in the train source file.

x_train_df <- read.table("./UCI HAR Dataset/train/X_train.txt", header=F, col.names = features_df$feature)

5. Read in the test data and store in x_test_df data frame. Set the column names to the feature values in the features_df data frame. Note that the features as listed by row in features.txt correspond by position to the data measurements captured by column in the test source file.

x_test_df <- read.table("./UCI HAR Dataset/test/X_test.txt", header=F, col.names = features_df$feature)

6. Read in the training data activity ids and store in the y_train_df data frame. Name the variables appropriately.

y_train_df <- read.table("./UCI HAR Dataset/train/y_train.txt", header=F, col.names = c("activity_id"))

7. Read in the test data activity ids and store in the y_test_df data frame. Name the variables appropriately.

y_test_df <- read.table("./UCI HAR Dataset/test/y_test.txt", header=F, col.names = c("activity_id"))

8. Read in the activities lookup info and store in the activities_df data frame. Name the variables appropriately.

activities_df <- read.table("./UCI HAR Dataset/activity_labels.txt", header=F, col.names = c("activity_id", "activity"))

9. Merge the activity labels in the activities_df data frame into the y_train_df activity ids by activity_id.

y_train_df <- merge(y_train_df, activities_df, by="activity_id", all=F)

10. Merge the activity labels in the activities_df data frame into the y_test_df activity ids by activity_id.

y_test_df <- merge(y_test_df, activities_df, by="activity_id", all=F)

11. Add an activity column to the x_train_df data frame from the y_train_df data frame's activity column. Note that activities recorded in the y_train source file correspond by row to the x_train data measurements. That is why we can simply add the column of activities to the data frame.

x_train_df$activity = y_train_df$activity

12. Add an activity column to the x_test_df data frame from the y_test_df data frame's activity column. Note that activities recorded in the y_test source file correspond by row to the x_test data measurements. That is why we can simply add the column of activities to the data frame.

x_test_df$activity = y_test_df$activity

13. Add a subject_id column to the x_train_df data frame from the subject_train_df data frame's subject_id column. Note that subjects recorded in the subject_train source file correspond by row to the x_train data measurements. That is why we can simply add the column of subjects to the data frame.

x_train_df$subject_id = subject_train_df$subject_id

14. Add a subject_id column to the x_test_df data frame from the subject_test_df data frame's subject_id column. Note that subjects recorded in the subject_test source file correspond by row to the x_test data measurements. That is why we can simply add the column of subjects to the data frame.

x_test_df$subject_id = subject_test_df$subject_id

15. Load the dplyr library.

library(dplyr)

16. Reorder the x_test_df columns using dplyr select function.

x_test_df <- x_test_df %>% select(subject_id, activity, everything())

17. Reorder the x_train_df columns using dplyr select function.

x_train_df <- x_train_df %>% select(subject_id, activity, everything())

18. Combine the x_train_df and x_test_df data frames by performing a union with rbind. Store in new data frame x_combined.

x_combined <- rbind(x_test_df, x_train_df)

19. From the x_combined column names list, find the variables that are means or standard deviations using grep regular expression function. Store resulting list in good_cols.

good_cols <- c(1, 2, grep("([Mm]ean|std)", colnames(x_combined)))

20. Create a new data frame, x_comb_ltd, which is comprised of only the columns in x_combined with names in the good_cols list.

x_comb_ltd <- x_combined[,good_cols]

21. Load the tidyr library.

library(tidyr)

22. Create the final data frame, tidy_means, by calculating the means of all the measurement variables grouping by subject_id and activity.

tidy_means <- x_comb_ltd %>% group_by(subject_id, activity) %>% summarize_at(.vars = names(.)[3:length(colnames(x_comb_ltd))], mean)
