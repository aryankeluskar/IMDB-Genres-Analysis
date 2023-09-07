# IMDB-MonteCarlo-Julia
Graph mean and variance of movies along the years. Then predict the average ratings by genres into the future, and finally use Monte Carlo Dropout to assess the uncertainties in my predictions.

## Overview

This is a data science project focused on analyzing over 730,000 entries of the IMDb dataset. The project aims to gain insights into genre-based movie ratings over the years, make genre-based predictions for the future, and assess uncertainties in those predictions using Monte Carlo Dropout.

## Dataset

We use the IMDb dataset, which can be obtained from [source link](https://datasets.imdbws.com). Of which, I am using title.basics.tsv.gz and name.basics.tsv.gz.

## Procedure

I extracted the data from the two archives into tsv files, then used data_filter.py to combine the tsv files into a single csv file. I filtered out the unneccesary columns, and only kept the movies that have atleast 500 votes to not let unpopular movies skew the data.

## Project Structure

### Part 1 - Data Processing, Graphing

finalData.csv contains the final filtered out data. IMDB_STL.jl is the main Julia file that goes through the csv data, and stores the data in DataFrames.jl and Arrays of type Float64. Then it uses Plots.jl to generate line graphs for average yearly ratings for every genre from the year 1900 to 2022.

### Challenge 2 - Predicting

I did try using Seasonal Trend Decomposition to obtain a STL Object, but it did not yield significant results. So currently I am trying to find another method to accomplish the task

### Part 3 - Assessing Uncertainity

I am currently planning to use Monte Carlo Dropout to assess the uncertainity in my predictions. 