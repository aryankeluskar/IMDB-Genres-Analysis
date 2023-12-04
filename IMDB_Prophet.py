"""
Trying to convert this code to Julia
"""

# import pip
# import sys
# package = 'prophet'
# if not package in sys.modules:
#     pip.main(['install', package])

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from prophet import Prophet

# Load the CSV data into a DataFrame
csv_data = pd.read_csv("finalData.csv")

startYearData = 1905

# Filter out movies with start years between startYearData and 2023
csv_data = csv_data[(csv_data['startYear'] > startYearData) &
                    (csv_data['startYear'] < 2023)]

# Define genres list
genresList = ["Action", "Comedy", "Drama", "Comedy", "Sci-Fi",
              "Fantasy", "Thriller", "Romance", "Adventure", "Mystery"]

# Initialize arrays for storing average ratings and counts
yearsRatingAvg = np.zeros(2023 - startYearData)
noOfYears = np.zeros(2023 - startYearData)
genresRatingAvg = np.zeros((10, 2023 - startYearData))
genresCount = np.zeros((10, 2023 - startYearData))


# Loop through the DataFrame
for index, row in csv_data.iterrows():
    year = row['startYear']
    rating = row['averageRating']
    for genreIterative in range(10):
        if genresList[genreIterative] in row['genres']:
            yearsRatingAvg[year - startYearData] += rating
            noOfYears[year - startYearData] += 1
            genresRatingAvg[genreIterative, year - startYearData] += rating
            genresCount[genreIterative, year - startYearData] += 1

# Compute the average ratings
for i in range(2023 - startYearData):
    if noOfYears[i] > 0:
        yearsRatingAvg[i] /= noOfYears[i]
    for genreIterative in range(10):
        if genresCount[genreIterative, i] > 0:
            genresRatingAvg[genreIterative,
                            i] /= genresCount[genreIterative, i]

# Plot the average ratings
plt.figure(figsize=(10, 6))
plt.plot(range(startYearData, 2023), yearsRatingAvg, label="Years")
plt.xlabel("Year")
plt.ylabel("Average Rating")
plt.legend()
plt.savefig("plotMeans.png")

# Plot genre-specific average ratings
for genreIterative in range(10):
    plt.figure(figsize=(10, 6))
    plt.plot(range(startYearData, 2023),
             genresRatingAvg[genreIterative, :], label=genresList[genreIterative])
    plt.xlabel("Year")
    plt.ylabel("Average Rating")
    plt.legend()
    # plt.savefig(f"plot{genresList[genreIterative]}.png")


df = pd.DataFrame({
    'ds': range(startYearData, startYearData + len(yearsRatingAvg)),
    'y': yearsRatingAvg
})
print(df)

m = Prophet()
m.fit(df)

future = m.make_future_dataframe(periods=365)
future.tail()

forecast = m.predict(future)
forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']].tail()
fig1 = m.plot(forecast).savefig("prophetFuture.png")