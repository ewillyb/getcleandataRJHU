# Author: Eric Bollinger [ewillyb@gmail.com]


subject_train_df <- read.delim2("./UCI HAR Dataset/train/subject_train.txt", header=F, col.names = c("subject_id"))
subject_test_df <- read.delim2("./UCI HAR Dataset/test/subject_test.txt", header=F, col.names = c("subject_id"))

features_df <- read.table("./UCI HAR Dataset/features.txt", header=F, col.names = c("feature_id", "feature"))

x_train_df <- read.table("./UCI HAR Dataset/train/X_train.txt", header=F, col.names = features_df$feature)
x_test_df <- read.table("./UCI HAR Dataset/test/X_test.txt", header=F, col.names = features_df$feature)

y_train_df <- read.table("./UCI HAR Dataset/train/y_train.txt", header=F, col.names = c("activity_id"))
y_test_df <- read.table("./UCI HAR Dataset/test/y_test.txt", header=F, col.names = c("activity_id"))

activities_df <- read.table("./UCI HAR Dataset/activity_labels.txt", header=F, col.names = c("activity_id", "activity"))

y_train_df <- merge(y_train_df, activities_df, by="activity_id", all=F)
y_test_df <- merge(y_test_df, activities_df, by="activity_id", all=F)

x_train_df$activity = y_train_df$activity

x_test_df$activity = y_test_df$activity

x_train_df$subject_id = subject_train_df$subject_id
x_test_df$subject_id = subject_test_df$subject_id

library(dplyr)

x_test_df <- x_test_df %>% select(subject_id, activity, everything())
x_train_df <- x_train_df %>% select(subject_id, activity, everything())

x_combined <- rbind(x_test_df, x_train_df)

good_cols <- c(1, 2, grep("([Mm]ean|std)", colnames(x_combined)))

x_comb_ltd <- x_combined[,good_cols]

library(tidyr)

tidy_means <- x_comb_ltd %>% group_by(subject_id, activity) %>% summarize_at(.vars = names(.)[3:length(colnames(x_comb_ltd))], mean)

