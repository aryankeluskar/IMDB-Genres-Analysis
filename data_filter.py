import pandas as pd
import csv
import time
start_time = time.time()

usefulCols = ['tconst', 'startYear', 'genres']

tsv_data1 = pd.read_csv('data.tsv', sep='\t')
tsv_data2 = pd.read_csv('data2.tsv', sep='\t', usecols=usefulCols)

tsv_data1['startYear']=tsv_data2['startYear']
tsv_data1['genres']=tsv_data2['genres']

print(tsv_data1)
del tsv_data2

query = tsv_data1[tsv_data1['numVotes'] > 10000]
df = pd.DataFrame.from_records(query)
df=df.drop(labels="numVotes", axis=1)
df=df.drop(labels="tconst", axis=1)
df=df[df.startYear != """\\N"""]
df=df[df.genres != """\\N"""]
# df=df.drop(labels="\\\N", axis=0)

#print(df)

combined_csv_filename = 'finalData.csv'
df.to_csv(combined_csv_filename, index=False)

print((time.time()-start_time))

# with open(r'finalData.csv', 'a', newline='') as csvfile:
#     fieldnames = ['averageRating', 'startYear', 'genres']
#     writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

#     writer.writerow(
#         {'averageRating': '10.0', 'startYear': '2023', 'genres': 'horror'})

# def filter_criteria(row):
#     # Replace 'column_name' with the actual column name you want to filter by
#     return row['numVotes'] > 15000


# # Load the TSV files into DataFrames
# file1 = 'data.tsv'
# file2 = 'data2.tsv'

# df1 = pd.read_table(file1, sep='\t')
# df2 = pd.read_table(file2, sep='\t')

# # Apply filtering criteria to both DataFrames
# filtered_df1 = df1[df1.apply(filter_criteria, axis=1)]
# filtered_df2 = df2[df2.apply(filter_criteria, axis=1)]

# # Select only the columns you want to keep in the final combined DataFrame
# # Replace 'columns_to_keep' with a list of column names you want to retain
# columns_to_keep = ['averageRating', 'startYear', 'genres']

# filtered_df1 = filtered_df1[columns_to_keep]
# filtered_df2 = filtered_df2[columns_to_keep]

# # Concatenate the filtered DataFrames
# combined_df = pd.concat([filtered_df1, filtered_df2], ignore_index=True)

# # Save the combined DataFrame as a CSV file
# combined_csv_filename = 'finalData.csv'
# combined_df.to_csv(combined_csv_filename, index=False)
