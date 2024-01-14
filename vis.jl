using JSON
using Plots

data = JSON.parsefile("./year2023.json")

p =  plot(x=data[1]["xAxisValues"],)
bse = [5,6,8]
ws = [14,15,1      ]

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

for key in [15,16,17,5,4,10,11,12,13]
    source = data[key]
    # @show name = source["name"]["de"] , key
    println(source["name"]["en"], " ", key)
end

coaletc = data[6]["data"] .+ data[7]["data"] .+ data[8]["data"] + data[9]["data"]
renew = data[15]["data"] .+ data[16]["data"] .+ data[17]["data"] + data[5]["data"] .+ data[4]["data"] .+ data[10]["data"] .+ data[11]["data"] .+ data[12]["data"]
other = data[13]["data"]
wind_solar = data[15]["data"] + data[16]["data"] + data[17]["data"] 
wind_solar_storage = data[15]["data"] + data[16]["data"] + data[17]["data"]  + data[11]["data"] .+ data[12]["data"]+ data[1]["data"]
tot = coaletc .+ renew .+ other
# plot!(p, data[1]["xAxisValues"], coaletc./tot, label="Coal etc")
plot!(p, data[1]["xAxisValues"], renew./tot, label="Renewables/(Renewables+Coal+Gas)")
@show avg = sum(renew)/sum(tot)
@show min = minimum(renew./tot)
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
A = float(zeros(length(data[1]["xAxisValues"])))
for i in [1:2; 4:17]
    A .+= data[i]["data"]
end
plot((A)./last)
plot((coaletc .+ renew .+ other)./last)

histogram(renew./last, label="Renewables/(Electronic Load)",norm=:probability, bins=0:0.2:1.2)
title!("Renewables vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("renewables proportion histogram.png")

histogram(wind_solar./last, label="(Wind + Solar)/(Electronic Load)",norm=:probability, bins=0:0.2:1.2)
title!("Wind + Solar vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("ws proportion histogram.png")

histogram(wind_solar_storage./last, label="(Wind + Solar + Storage)/(Electronic Load)",norm=:probability, bins=0:0.2:1.2)
title!("Wind + Solar + Storage vs electronic load in 2023")
xlabel!("Proportion of the total energy demand per hour in 2023")
ylabel!("Proportion of hours in 2023")
savefig("ws storage proportion histogram.png")
