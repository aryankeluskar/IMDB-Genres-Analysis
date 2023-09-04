using DataFrames
using CSV
using Plots
using StatsPlots
using Forecast

""" Future Feature Request: Use weighted average to get the perceived average ratings of movies, assign weight using number of votes. Display both results """

csv_data = DataFrame(CSV.File("finalData.csv"))
# csv_data[!, :startYearInt] = [parse(Int,x) for x in csv_data[!, :startYear]] 
# csv_data[!, :averageRatingInt] = [parse(Int,x) for x in csv_data[!, :averageRating]] 
println(typeof(csv_data[!, "startYear"]), typeof(csv_data[!, "averageRating"]))

yearsRatingAvg = Array{Float64}(undef, 123)
noOfYears = zeros(123)
# yearsRatingVariance = Array{Float64}(undef, 123)

genresList = ["Action", "Comedy", "Drama", "Comedy", "Sci-Fi", "Fantasy", "Thriller", "Romance", "Adventure", "Mystery"]
genresRatingAvg = zeros(10, 123)
println(typeof(genresRatingAvg))
genresCount = zeros(10, 123)
# genresRatingVariance = zeros(10, 123)

# Looping through the DataFrame
for row in eachrow(csv_data)
    if (2023 > row.startYear > 1900 ) # Filtering out really old movies and movies yet to be released

        # To compute average, I am first calculating the sum of the ratings of the movies in a year
        yearsRatingAvg[row.startYear-1900] += (row.averageRating)

        # Counting how many movies fulfill this
        noOfYears[row.startYear-1900] += 1

        # Looping through the list of genres
        for genreIterative in range(1, 10, step=1)

            # Using contains since films belong to multiple genres``
            if (contains(row.genres, genresList[genreIterative]))

                # To compute average, I am first calculating the sum of the ratings that genre in a year
                genresRatingAvg[genreIterative, row.startYear-1900] += (row.averageRating)

                # Counting how many movies of that genre fulfill this
                genresCount[genreIterative, row.startYear-1900] += 1
            end
        end
    end
end

# Looping through the arrays that contain the sum of ratings
for yearsIterative in range(1, 123, step=1)
    # Computing average by dividing sum by count
    yearsRatingAvg[yearsIterative] /= noOfYears[yearsIterative]
    for genreIterative in range(1, 10, step=1)
        genresRatingAvg[genreIterative, yearsIterative] /= genresCount[genreIterative, yearsIterative]
    end
end


# for i in range(1, 123, step=1)
#     c = 0
#     for row in eachrow(csv_data)
#         if (row.startYear - 1900 == i)
#             yearsRatingVariance[i] += ((row.averageRating - yearsRatingAvg[i])^2.0)
#             c += 1
#         end
#     end
#     yearsRatingVariance[i] /= c
# end


# println(yearsRatingAvg)
pMeans = plot(yearsRatingAvg, label=["Years", "Ratings"])
savefig(pMeans, "plotMeans.png")
for genreIterative in range(1, 10, step=1)
    savefig(plot(genresRatingAvg[genreIterative, :], label=genresList[genreIterative]), ("plot" * genresList[genreIterative] * ".png"))
end

# pVariance = plot(yearsRatingVariance, label=["Years", "Variance"])
# savefig(pVariance, "plotVariance.png")
# plot(csv_data["startYear"], csv_data["averageRating"])

# Note to self: It is possible to directly Read from a zip file!
# stl_movies = stl(yearsRatingAvg, length(yearsRatingAvg); )
# println(stl_movies)
# pStl = plot(stl_movies, label=["Years", "Variance"])
# savefig(pStl, "plotStl.png")

"""STL Object with robust=false: stl(Yn, np=123; nl=123, ns=1231, nt=185, ni=2, no=0, spm=false, qsmp=17)"""