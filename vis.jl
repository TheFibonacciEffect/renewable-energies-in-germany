using JSON
using Plots

data = JSON.parsefile("./year2023.json")


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
const Hydro_Run_of_River_index=4
const Biomass_index=5
const Fossil_brown_coal_lignite_index=6
const Fossil_hard_coal_index=7
const Fossil_oil_index=8
const Fossil_gas_index=9
const Geothermal_index=10
const Hydro_water_reservoir_index=11
const Hydro_pumped_storage_index=12
const Others_index=13
const Waste_index=14
const Wind_offshore_index=15
const Wind_onshore_index=16
const Solar_index=17
const Load_index=18
const Residual_load_index=19
const Renewable_share_of_generation_index=20
const Renewable_share_of_load_index=21
const Day_Ahead_Auction_index=22
for key in keys(data)
    source = data[key]
    println("const ",replace(source["name"]["en"]," "=>"_"),"_index", "=", key)
end

d(i)::Vector{Float64} = replace(data[i]["data"], nothing => NaN)


# define the groups of the sources
coaletc = data[6]["data"] .+ data[7]["data"] .+ data[8]["data"] + data[9]["data"]
renew = data[15]["data"] .+ data[16]["data"] .+ data[17]["data"] + data[5]["data"] .+ data[4]["data"] .+ data[10]["data"] .+ data[11]["data"] .+ data[12]["data"]
other = data[13]["data"]
wind_solar = data[15]["data"] + data[16]["data"] + data[17]["data"] 
wind_solar_storage = data[15]["data"] + data[16]["data"] + data[17]["data"]  + data[11]["data"] .+ data[12]["data"]+ data[1]["data"]
combined_renew_coal_other = coaletc .+ renew .+ other
resudallast = data[19]["data"] # https://de.wikipedia.org/wiki/Residuallast

all_except_nuclear = float(zeros(length(data[1]["xAxisValues"])))
for i in [1:2; 4:17]
    all_except_nuclear .+= data[i]["data"]
end

p =  plot(x=data[1]["xAxisValues"],)
plot!(p, data[1]["xAxisValues"], renew./combined_renew_coal_other, label="Renewables/(Renewables+Coal+Gas)")
@show avg = sum(renew)/sum(combined_renew_coal_other)
@show min = minimum(renew./combined_renew_coal_other)
plot!(p, data[1]["xAxisValues"], avg*ones(length(data[1]["xAxisValues"])), label="Average", linestyle=:dash)
p
savefig(p, "renewables proportion.png")

ee_vs_last = data[21]["data"]
min = minimum(data[21]["data"])
maximum(data[21]["data"])
last = data[18]["data"]


plot(renew./last)
@show minimum(renew./last)*(sum(last)/sum(renew))
@show minimum(renew./last)
@show maximum(renew./last)


plot(coaletc./last)
@show minimum(coaletc./last)
@show maximum(coaletc./last)
plot((all_except_nuclear)./last)
plot((coaletc .+ renew .+ other)./last)


bins = 0:0.2:1.2
histogram(renew./last, label="Renewables/(Electronic Load)",norm=:probability, bins=bins)
title!("Renewables vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("renewables proportion histogram.png")

histogram(wind_solar./last, label="(Wind + Solar)/(Electronic Load)",norm=:probability, bins=bins)
title!("Wind + Solar vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("ws proportion histogram.png")

histogram(wind_solar_storage./last, label="(Wind + Solar + Storage)/(Electronic Load)",norm=:probability, bins=bins)
title!("Wind + Solar + Storage vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("ws storage proportion histogram.png")

histogram(resudallast./last, label="Residual Load/(Electronic Load)",norm=:probability, bins=bins)
title!("Residual Load vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("residual load proportion histogram.png")

histogram(coaletc./last, label="Coal + Gas/(Electronic Load)",norm=:probability, bins=[0:0.1:1.1;])
title!("Coal + Gas vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("coal gas proportion histogram.png")

histogram(d(Day_Ahead_Auction_index), label="Day Ahead Auction",norm=:probability,bins=-5:10:200) 
ylabel!("Number of hours in 2023")
xlabel!("Price of electricity in €/MWh")
title!("Day Ahead Auction prices in 2023")
savefig("day ahead auction prices.png")

n = d(Day_Ahead_Auction_index) |> length

scatter((d(Solar_index).+d(Wind_offshore_index).+d(Wind_onshore_index))./3,d(Day_Ahead_Auction_index), label="Solar", color=:orange)
xlabel!("mean Solar + Wind production")
ylabel!("auction price")
title!("Day Ahead Auction prices in 2023")
savefig("Day ahead auction prices.png")