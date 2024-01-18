using JSON
using Plots

data = JSON.parsefile("../year2023.json")


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

scalable_renewables = d(Wind_offshore_index) .+ d(Wind_onshore_index) .+ d(Solar_index)
other_renewables = d(Hydro_Run_of_River_index) .+ d(Biomass_index) .+ d(Geothermal_index) .+ d(Waste_index)

function run_model(initial_storage, multiplier)
    storage = initial_storage
    max_storage = initial_storage
    dt = 365*24/length(d(Load_index))
    for (l,p) in zip(d(Load_index), multiplier*scalable_renewables)
           storage += (p - l) * dt
            if storage < 0
                return false # infeasible
            end
            if storage > max_storage
                max_storage = storage # find maximum needed storage
            end
    end
    return storage, max_storage
end

for i in 10 .^range(1,10,length=10)
    run_model(i,1)
end

function find_i(s)
    i = 1
    while (x=run_model(i,s)) == false
        i *= 2
    end
    return i,x
end

for s in 1:10
    println(find_i(s))
end
