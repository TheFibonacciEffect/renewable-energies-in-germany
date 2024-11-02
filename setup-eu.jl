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
wind = data[Wind_offshore_index]["data"] .+ data[Wind_onshore_index]["data"]
solar = data[Solar_index]["data"]