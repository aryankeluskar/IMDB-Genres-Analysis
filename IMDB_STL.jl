using DataFrames
using CSV
using Plots
using StatsPlots
using Forecast

csv_data = DataFrame(CSV.File("finalData.csv"))
# csv_data[!, :startYearInt] = [parse(Int,x) for x in csv_data[!, :startYear]] 
# csv_data[!, :averageRatingInt] = [parse(Int,x) for x in csv_data[!, :averageRating]] 
println(typeof(csv_data[!, "startYear"]), typeof(csv_data[!, "averageRating"]))
yearsRatingAvg = Array{Float64}(undef, 123)
yearsRatingVariance = Array{Float64}(undef, 123)

for row in eachrow(csv_data)
    if (row.startYear > 1900)
        yearsRatingAvg[row.startYear-1900] = (yearsRatingAvg[row.startYear-1900] + (row.averageRating)) / 2
    end
end


for i in range(1, 123, step=1)
    c=0
    for row in eachrow(csv_data)
        yearsRatingVariance[i]+=((row.averageRating-yearsRatingAvg[i])^2.0)
        c+=1
    end
    yearsRatingVariance[i]/=c
end


# println(yearsRatingAvg)

pMeans = plot(yearsRatingAvg, label=["Years", "Ratings"])
savefig(pMeans, "plotMeans.png")
pVariance = plot(yearsRatingVariance, label=["Years", "Variance"])
savefig(pVariance, "plotVariance.png")
# plot(csv_data["startYear"], csv_data["averageRating"])

# Note to self: It is possible to directly Read from a zip file!
stl_movies = stl(yearsRatingAvg, length(yearsRatingAvg); )
println(stl_movies)
pStl = plot(stl_movies, label=["Years", "Variance"])
savefig(pStl, "plotStl.png")

"""STL Object with robust=false: stl(Yn, np=123; nl=123, ns=1231, nt=185, ni=2, no=0, spm=false, qsmp=17)"""