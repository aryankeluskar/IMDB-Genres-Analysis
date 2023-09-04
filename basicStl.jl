using DataFrames
using CSV
using Plots
using StatsPlots
using Forecast
using Dates
using SeasonalTrendLoess
using Test

# Trying out STL Predictions with a dataset that I know follows seasonal trends, ie: searches for the month of August on Google
# Using my experience in this, I will proceed to decomp the IMDB Data since it too features spikes in ratings in near-regular intervals of timings

aug_data = DataFrame(CSV.File("augustSearches.csv"))
savefig(plot(aug_data.Week, aug_data.august), "augustPlot.png")
s = stl(aug_data.august, 12;)
println(s)
# augustStl = stl((aug_data.august, aug_data.Week-firstDate);)
# savefig(plot(augustStl), "augStl.png")
