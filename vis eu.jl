using JSON
using Plots

data = JSON.parsefile("./year_2023_eu.json")


# "Pumpspeicher Verbrauch"                  1
# "Grenzüberschreitender Stromhandel"       2
# "Kernenergie"     3
# "Laufwasser"      4
# "Biomasse"        5
# "Braunkohle"      6
# "Steinkohle"      7
# "Öl"      8
# "Erdgas"      9
# "Geothermie",    10
# "Speicherwasser",    11
# "Pumpspeicher",      12
# "Andere",    13
# "Müll",      14
# "Wind Offshore",     15
# "Wind Onshore",      16
# "Solar",     17
# "Last",      18
# "Residuallast",      19
# "Anteil EE an der Erzeugung",             20
# "Anteil EE an der Last",     21

const Hydro_pumped_storage_consumption_index=1
const Cross_border_electricity_trading_index=2
const Nuclear_index=3
const Hydro_RunofRiver_index=4
const Biomass_index=5
const Fossil_brown_coal_lignite_index=6
const Fossil_hard_coal_index=7
const Fossil_peat_index=8
const Fossil_oil_index=9
const Fossil_oil_shale_index=10
const Fossil_coalderived_gas_index=11
const Fossil_gas_index=12
const Geothermal_index=13
const Hydro_water_reservoir_index=14
const Hydro_pumped_storage_index=15
const Others_index=16
const Other_renewables_index=17
const Waste_index=18
const Wind_offshore_index=19
const Wind_onshore_index=20
const Solar_index=21
const Load_index=22
const Residual_load_index=23
const Renewable_share_of_generation_index=24
const Renewable_share_of_load_index=25
for key in keys(data)
    source = data[key]
    println("const ",replace(source["name"]["en"]," "=>"_"),"_index", "=", key)
end

d(i)::Vector{Float64} = replace(data[i]["data"], nothing => NaN)


# define the groups of the sources
# coaletc = data[6]["data"] .+ data[7]["data"] .+ data[8]["data"] + data[9]["data"]
# renew = data[15]["data"] .+ data[16]["data"] .+ data[17]["data"] + data[5]["data"] .+ data[4]["data"] .+ data[10]["data"] .+ data[11]["data"] .+ data[12]["data"]
# other = data[13]["data"]
# wind_solar = data[15]["data"] + data[16]["data"] + data[17]["data"] 
# wind_solar_storage = data[15]["data"] + data[16]["data"] + data[17]["data"]  + data[11]["data"] .+ data[12]["data"]+ data[1]["data"]
# combined_renew_coal_other = coaletc .+ renew .+ other
# resudallast = data[19]["data"] # https://de.wikipedia.org/wiki/Residuallast

coaletc = data[Fossil_brown_coal_lignite_index]["data"] .+ data[Fossil_hard_coal_index]["data"] .+ data[Fossil_peat_index]["data"] + data[Fossil_gas_index]["data"]
renew = data[Wind_offshore_index]["data"] .+ data[Wind_onshore_index]["data"] .+ data[Solar_index]["data"] + data[Biomass_index]["data"] .+ data[Hydro_RunofRiver_index]["data"] .+ data[Geothermal_index]["data"] .+ data[Hydro_water_reservoir_index]["data"] .+ data[Hydro_pumped_storage_index]["data"]
other = data[Others_index]["data"]
wind_solar = data[Wind_offshore_index]["data"] + data[Wind_onshore_index]["data"] + data[Solar_index]["data"]
wind_solar_storage = data[Wind_offshore_index]["data"] + data[Wind_onshore_index]["data"] + data[Solar_index]["data"]  + data[Hydro_water_reservoir_index]["data"] .+ data[Hydro_pumped_storage_index]["data"]+ data[Hydro_pumped_storage_consumption_index]["data"]
combined_renew_coal_other = coaletc .+ renew .+ other
resudallast = data[Residual_load_index]["data"] # https://de.wikipedia.org/wiki/Residuallast



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
