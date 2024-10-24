
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
# "load",      18
# "Residualload",      19
# "Anteil EE an der Erzeugung",             20
# "Anteil EE an der load",     21

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
resudalload = data[19]["data"] # https://de.wikipedia.org/wiki/Residualload

all_except_nuclear = float(zeros(length(data[1]["xAxisValues"])))
for i in [1:2; 4:17]
    all_except_nuclear .+= data[i]["data"]
end