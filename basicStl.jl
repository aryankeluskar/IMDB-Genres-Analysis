using DataFrames
using CSV
using Plots
using StatsPlots
using Forecast
using Dates

aug_data = DataFrame(CSV.File("augustSearches.csv"))
savefig(plot(aug_data.Week, aug_data.august), "augustPlot.png")
firstDate = Dates.Date(2018,09,02)
println(aug_data.iloc[[5]].Week-firstDate)
# augustStl = stl((aug_data.august, aug_data.Week-firstDate);)
# savefig(plot(augustStl), "augStl.png")