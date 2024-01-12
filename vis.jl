using JSON
using Plots

data = JSON.parsefile("./frauenhofer july 2023.json")

p =  plot(x=data[1]["xAxisValues"],)
bse = [5,6,8]
ws = [14,15,16]

coaletc = data[5]["data"] .+ data[6]["data"] .+ data[8]["data"]
renew = data[14]["data"] .+ data[15]["data"] .+ data[16]["data"]

plot!(p, data[1]["xAxisValues"], coaletc, label="Coal etc")
plot!(p, data[1]["xAxisValues"], renew, label="Renewables")
plot!(p, data[1]["xAxisValues"], coaletc .+ renew , label="Total")
p