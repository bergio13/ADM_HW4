#!/bin/bash

# Set the path to the dataset file
dataset_path="/home/cloudshell-user/vodclickstream_uk_movies_03.csv"

# Define column numbers based on the provided structure
datetime_column=2
duration_column=3
title_column=4
user_id_column=8


# 1. What is the most-watched Netflix title?
echo "The most-watched Netflix title is..."

# Extract relevant columns and use AWK to sum the duration for each title
tail -n +2 "$dataset_path" | # Skip the header line
awk -F, -v duration_col="$duration_column" -v title_col="$title_column" 'NR>1 {gsub(/"/, "", $title_col); duration[$title_col]+=$duration_col} END {max_duration=0; for (title in duration) if (duration[title] > max_duration) {max_duration=duration[title]; max_title=title}} END {print "Title:", max_title, "Total Duration:", max_duration}'

# 2. Report the average time between subsequent clicks on Netflix.com
echo "The average time between subsequent clicks on Netflix is..."

# Extract the datetime and user_id columns
tail -n +2 "$dataset_path" | # Skip the header line
cut -d, -f"$datetime_column,$user_id_column" |
tr -d '"' |
sort -t',' -k2,2 -k1,1 |  # Sort by user_id and then by datetime
awk -F, '{if ($2 != prev_user) {prev_user = $2; prev_time = $1} else {print $1 - prev_time}}' |
awk '{sum += $1; count++} END {if (count > 0) print "Average time (seconds):", sum / count; else print "No subsequent clicks to calculate average time."}'


# 3.Provide the ID of the user that has spent the most time on Netflix
echo "The ID of the user & total duration is..."

# Sum the duration for each user and find the one with the maximum duration
tail -n +2 "$dataset_path" | 
awk -F, -v duration_col="$duration_column" -v user_col="$user_id_column" 'NR>1 {gsub(/"/, "", $user_col); if ($user_col ~ /^[a-f0-9]+$/) duration[$user_col]+=$duration_col} END {for (user in duration) if (duration[user] > max_duration) {max_duration=duration[user]; max_user=user}} END {print "User ID:", max_user, "Total Duration:", max_duration}'
