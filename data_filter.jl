using DataFrames
using CSV
using Plots

csv_data = DataFrame(CSV.File("finalData.csv"))
# csv_data[!, :startYearInt] = [parse(Int,x) for x in csv_data[!, :startYear]] 
# csv_data[!, :averageRatingInt] = [parse(Int,x) for x in csv_data[!, :averageRating]] 
println(typeof(csv_data[!, "startYear"]), typeof(csv_data[!, "averageRating"]))
yearsRatingAvg = Array{Float64}(undef, 123)

for row in eachrow(csv_data)
    if (row.startYear > 1900)
        yearsRatingAvg[row.startYear-1900] = (yearsRatingAvg[row.startYear-1900]+(row.averageRating))/2
    end
end

# println(yearsRatingAvg)

p=plot(yearsRatingAvg, label= ["Years", "Ratings"])
savefig(p,"plot.png")
# plot(csv_data["startYear"], csv_data["averageRating"])

# Note to self: It is possible to directly Read from a zip file!