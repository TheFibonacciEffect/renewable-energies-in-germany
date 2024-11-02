using Statistics
using JSON
using Plots

include("setup-de.jl")
renew
median(renew)
mean(renew)
quantile(renew, 0.005)
quantile(wind, 0.005)

quantile(solar, 0.005)
mean(solar)
maximum(solar)

mean(wind_solar)
quantile(wind_solar, 0.005)

function dunkelflaute(x, threshhold)
    sum((x ./ maximum(x)) .< threshhold) / length(x)*100
end
threshholds = 0:0.05:1.0
rate = zero(threshholds)
for i in eachindex(threshholds)
    rate[i] = dunkelflaute(wind_solar, threshholds[i])
end
plot(threshholds, rate, xlabel="threshhold as % of max power", ylabel="% of year under threshhold", label="wind + solar")
savefig("plots/dunkelflaute.png")

function length_of_dunkelflaute(x, threshhold, length_cutoff)
    l = []
    dt = 365*24/length(x) # hours
    m = maximum(x)
    i = 1
    while i < length(x)
        len = 0
        while x[i]/m < threshhold # we are inside a dunkelflaute
            i+=1
            len += 1 # increase the length counter
        end
        if len >= length_cutoff push!(l, len) end
        i += 1
    end
    return l * dt
end

histogram(length_of_dunkelflaute(wind_solar, 0.1, 1), xlabel="length in hours", ylabel="amount of occurences", label="length of dunkelflaute", xaxis=0:12:24*10)
savefig("plots/length_of_dunkelflaute.png")