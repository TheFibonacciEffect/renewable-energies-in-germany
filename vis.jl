using JSON
using Plots

data = JSON.parsefile("./frauenhofer july 2023.json")

p =  plot(x=data[1]["xAxisValues"],)
bse = [5,6,8]
ws = [14,15,16]
for key in [bse ws]
    @show key
    source = data[key]
    @show name = source["name"]["de"]
    plot!(p, source["data"], label=name, legend=:topleft)
end

p