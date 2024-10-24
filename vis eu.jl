using JSON
using Plots

include("setup-eu.jl")


plot(coaletc./d(Load_index))
@show minimum(coaletc./d(Load_index))
@show maximum(coaletc./d(Load_index))
plot((coaletc .+ renew .+ other .+ d(Nuclear_index))./d(Load_index))

plot(d(Nuclear_index)./d(Load_index))

bins = 0:0.2:1.2
histogram(renew./d(Load_index), label="Renewables/(Electronic Load)",norm=:probability, bins=bins)
title!("Renewables vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/renewables proportion histogram.png")

histogram(wind_solar./d(Load_index), label="(Wind + Solar)/(Electronic Load)",norm=:probability, bins=bins)
title!("Wind + Solar vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/ws proportion histogram.png")



histogram(wind_solar_storage./d(Load_index), label="(Wind + Solar + Storage)/(Electronic Load)",norm=:probability, bins=bins)
title!("Wind + Solar + Storage vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/ws storage proportion histogram.png")

histogram(resudallast./d(Load_index), label="Residual Load/(Electronic Load)",norm=:probability, bins=bins)
title!("Residual Load vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/residual load proportion histogram.png")

histogram(coaletc./d(Load_index), label="Coal + Gas/(Electronic Load)",norm=:probability, bins=[0:0.1:1.1;])
title!("Coal + Gas vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/coal gas proportion histogram.png")


histogram(d(Nuclear_index) ./ d(Load_index), label="Nuclear",norm=:probability,bins=bins)
title!("Nuclear vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/nuclear proportion histogram.png")

histogram(d(Solar_index) ./ d(Load_index), label="Solar",norm=:probability,bins=bins)
@show maximum(d(Solar_index) ./ d(Load_index))
@show minimum(d(Solar_index) ./ d(Load_index))
title!("Solar vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/solar proportion histogram.png")

# ws vs nuclear
bins = 0:0.05:0.6
histogram(wind_solar./d(Load_index), label="(Wind + Solar)/(Electronic Load)",norm=:probability, bins=bins)
histogram!(d(Nuclear_index) ./ d(Load_index), label="Nuclear",norm=:probability, bins=bins)
title!("Wind + Solar vs nuclear vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/ws proportion histogram.png")
histogram2d(d(Nuclear_index)./d(Load_index), wind_solar./d(Load_index), norm=:probability, show_empty_bins=true, xlabel="Nuclear", ylabel="Wind + Solar", bins = (0:0.05:0.6, 0:0.05:0.6))

# bei 5 fachen ausbau
histogram(5 .*wind_solar - d(Load_index), label="(Wind + Solar)/(Electronic Load)",norm=:probability)
title!("Wind + Solar vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("plots/ws proportion histogram.png")


function feasabililty(n)
    dt = 365*24/length(wind_solar)
    storeage = 0
    max_storage = 0
    min_stogare = 0
    storage_over_time = Array{Float64}(undef, length(wind_solar))
    for (i,(p,l)) in enumerate(zip(n.*wind_solar, d(Load_index)))
        storeage += (p-l)*dt # Watt Hours
        storage_over_time[i] = storeage
        if storeage > max_storage max_storage = storeage end
        if storeage < min_stogare min_stogare = storeage end
    end
    @show max_storage
    @show min_stogare
    @show storeage
    return storage_over_time
end

feasabililty(4) |> plot
# # plot everything
# p = histogram(figsize=4 .*(800,600))
# for i in 1:20
#     p = histogram!(d(i)./d(Load_index), label=data[i]["name"]["en"],norm=:probability,bins=bins, bar_position=:stacked, figsize=4 .*(800,600))
# end
# p

using StatsPlots
bins = range(0,1e5,100)
# groupedbar([d(Nuclear_index)  d(Solar_index)  d(Wind_offshore_index)  d(Wind_onshore_index)], bar_position=:stacked, label=["Nuclear" "Solar" "Wind Offshore" "Wind Onshore"], norm=:probability, show_empty_bins=true, fillalpha=0.5)
groupedhist([d(Nuclear_index)  d(Solar_index)  d(Wind_offshore_index)  d(Wind_onshore_index)], label=["Nuclear" "Solar" "Wind Offshore" "Wind Onshore"], bins=bins, bar_position=:stacked)
histogram(d.([Nuclear_index, Wind_onshore_index]), label=["Nuclear" "Solar"], bins=bins, norm=:probability, show_empty_bins=true, bar_position=:stacked, fillalpha=0.5)
histogram(d.([Nuclear_index, Wind_onshore_index]), label=["Nuclear" "Solar"], bins=bins, norm=:probability, show_empty_bins=true)

# if more wind then less solar and vice versa
bins = 0.01:0.03:0.6
histogram2d(d(Solar_index)./d(Load_index),( d(Wind_offshore_index) .+ d(Wind_onshore_index))./d(Load_index), norm=:probability, show_empty_bins=true, bins = (bins, bins), xlabel="Solar", ylabel="Wind")



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
histogram2d( x ./ maximum(x) * 12, wind_solar./last, bins=(12,10), norm=:probability, show_empty_bins=false)

N = 20
