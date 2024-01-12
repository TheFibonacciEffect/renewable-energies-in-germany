using JSON
using Plots

data = JSON.parsefile("./year2023.json")

p =  plot(x=data[1]["xAxisValues"],)
bse = [5,6,8]
ws = [14,15,16]

coaletc = data[5]["data"] .+ data[6]["data"] .+ data[8]["data"]
renew = data[14]["data"] .+ data[15]["data"] .+ data[16]["data"]
tot = coaletc .+ renew
# plot!(p, data[1]["xAxisValues"], coaletc./tot, label="Coal etc")
plot!(p, data[1]["xAxisValues"], renew./tot, label="Renewables/(Renewables+Coal+Gas)")
@show avg = sum(renew)/sum(tot)
plot!(p, data[1]["xAxisValues"], avg*ones(length(data[1]["xAxisValues"])), label="Average", linestyle=:dash)
savefig(p, "renewables proportion.png")
p