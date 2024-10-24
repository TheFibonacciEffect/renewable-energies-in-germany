using JSON
using Plots
using Measurements

include("setup-de.jl")

p =  plot(x=data[1]["xAxisValues"],)
plot!(p, data[1]["xAxisValues"], renew./combined_renew_coal_other, label="Renewables/(Renewables+Coal+Gas)")
@show avg = sum(renew)/sum(combined_renew_coal_other)
@show min = minimum(renew./combined_renew_coal_other)
plot!(p, data[1]["xAxisValues"], avg*ones(length(data[1]["xAxisValues"])), label="Average", linestyle=:dash)
p
savefig(p, "plots/renewables proportion.png")

ee_vs_load = data[21]["data"]
min = minimum(data[21]["data"])
maximum(data[21]["data"])
load = data[18]["data"]


plot(renew./load)
@show minimum(renew./load)*(sum(load)/sum(renew))
@show minimum(renew./load)
@show maximum(renew./load)


plot(coaletc./load)
@show minimum(coaletc./load)
@show maximum(coaletc./load)
plot((all_except_nuclear)./load)
plot((coaletc .+ renew .+ other)./load)


bins = 0:0.2:1.2
histogram(renew./load, label="Renewables/(Electronic Load)",norm=:probability, bins=bins)
title!("Renewables vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/renewables proportion histogram.png")

histogram(wind_solar./load, label="(Wind + Solar)/(Electronic Load)",norm=:probability, bins=bins)
title!("Wind + Solar vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/ws proportion histogram.png")

histogram(wind_solar_storage./load, label="(Wind + Solar + Storage)/(Electronic Load)",norm=:probability, bins=bins)
title!("Wind + Solar + Storage vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/ws storage proportion histogram.png")

histogram(resudalload./load, label="Residual Load/(Electronic Load)",norm=:probability, bins=bins)
title!("Residual Load vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/residual load proportion histogram.png")

histogram(coaletc./load, label="Coal + Gas/(Electronic Load)",norm=:probability, bins=[0:0.1:1.1;])
title!("Coal + Gas vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/coal gas proportion histogram.png")

histogram(d(Day_Ahead_Auction_index), label="Day Ahead Auction",norm=:probability,bins=-5:10:200) 
ylabel!("Number of hours in 2023")
xlabel!("Price of electricity in €/MWh")
title!("Day Ahead Auction prices in 2023")
savefig("plots/day ahead auction prices.png")

# using StatsPlots
# n = d(Day_Ahead_Auction_index) |> length
# marginalkde((d(Solar_index).+d(Wind_offshore_index).+d(Wind_onshore_index))./3,d(Day_Ahead_Auction_index), label="Solar")
# xlabel!("mean Solar + Wind production")
# ylabel!("auction price")
# title!("Day Ahead Auction prices in 2023")
# savefig("plots/Day ahead auction prices.png")


histogram2d(d(Day_Ahead_Auction_index), (d(Solar_index).+d(Wind_offshore_index).+d(Wind_onshore_index))./3 ./d(Load_index), bins=(0:5:200,20), label="Solar + Wind", norm=:probability, show_empty_bins=true)
xlabel!("Price of electricity in €/MWh")
ylabel!("Solar + Wind production / Load")
savefig("plots/price vs solar wind.png")

histogram2d(d(Day_Ahead_Auction_index), d(Residual_load_index)./d(Load_index), bins=(10 .^ range(1.7,2.3,50), 10 .^ range(-.5,0,50)), xscale=:log10, yscale=:log10, label="Solar + Wind", norm=:probability, show_empty_bins=true)
histogram2d(d(Day_Ahead_Auction_index), d(Residual_load_index)./d(Load_index), bins=(10 .^ range(1.7,2.3,50), 50), xscale=:log10, label="Solar + Wind", norm=:probability, show_empty_bins=true)
histogram2d(d(Day_Ahead_Auction_index), d(Residual_load_index)./d(Load_index), bins=(range(-20,250,50), 50), label="Solar + Wind", norm=:probability, show_empty_bins=true)
xlabel!("Price of electricity in €/MWh")
ylabel!("Residual Load / Load")
title!("Price of electricity vs Residual Load in 2023")
savefig("plots/price vs residual load.png")

# those two are more or less uncorrrelated
histogram2d(d(Day_Ahead_Auction_index), d(Cross_border_electricity_trading_index)./d(Load_index), bins=(range(-20,250,50), 50), label="Solar + Wind", norm=:probability, show_empty_bins=true)
xlabel!("Price of electricity in €/MWh")
ylabel!("Cross border electricity trading / Load")
title!("Price of electricity vs electricity trading")
savefig("plots/price vs cross border electricity trading.png")

x = float.(data[1]["xAxisValues"])
histogram2d( x ./ maximum(x) * 12, wind_solar./load, bins=(12,10), norm=:probability, show_empty_bins=false)

N = 20
using Unitful
using AdditionalUnits
# Greenhouse gas emissions: https://ourworldindata.org/safest-sources-of-energy
dt = 1u"yr"/length(wind_solar)
# per TWh
deaths = Dict(
    "Coal" => 24.6/(u"TW*hr"),
    "Oil"  => 18.6/(u"TW*hr"),
    "Natural Gas" => 2.8/(u"TW*hr"),
    "Biomass" => 4.6/(u"TW*hr"),
    "Hyropower" => 1.3/(u"TW*hr"),
    "Wind" => 0.04/(u"TW*hr"),
    "Nuclear" => 0.03/(u"TW*hr"),
    "Solar" => 0.02/(u"TW*hr")
)
deaths = deaths

# per GWh
co2 = Dict(
    "Coal" => 970u"ton"/u"GW*hr",
    "Oil" => 720u"ton"/u"GW*hr",
    "Natural Gas" => 440u"ton"/u"GW*hr",
    "Biomass" => ((78+230)/2 ± (230-78)/2)u"ton"/u"GW*hr",
    "Hydropower" => 24u"ton"/u"GW*hr",
    "Wind" => 11u"ton"/u"GW*hr",
    "Nuclear" => 6u"ton"/u"GW*hr",
    "Solar" => 53u"ton"/u"GW*hr"
)


uconvert(NoUnits,sum(d(Solar_index)*u"MW"*dt*deaths["Solar"]))
uconvert(u"ton",sum(d(Solar_index)*u"MW"*dt*co2["Solar"]))


uconvert(u"TWh", sum(d(Load_index)*u"MW"*dt) ) # energy demand in germany per year?