
using JuMP
using HiGHS
using JSON
using Plots
using IterTools
using Memoize

function create_model(Qmax, s, pi, po, N, dt)
    # s is how much more renewable energy we have than we have currently
    o = optimizer_with_attributes(HiGHS.Optimizer, "presolve" => "on")
    m = Model(o)
    set_silent(m)

    @variable(m, 0 <= q[1:N] <= Qmax)

    for i = 1:N-1
        @constraint(m, (q[i+1] - q[i]) / dt <= s * pi[i] - po[i]) 
    end

    @constraint(m, q[N] >= q[1]) # at the end of the year, we must have as much as we started with

    @objective(m, Min, q[1])

    return m
end

function creator(pi, po, dt)
    @assert length(pi) == length(po)
    return (Qmax, s) -> create_model(Qmax, s, pi, po, length(pi), dt)
end

function load_data(file)
    return JSON.parsefile(file)
end

const nuclear_index = 3
const hydro_flowing_index = 4
const biomass_index = 5
const lignite_index = 6
const coal_index = 7
const oil_index = 8
const natural_gas_index = 9
const geothermal_index = 10
const hydro_speicher_index = 11
const hydro_pump_index = 12
const others_index = 13
const waste_index = 14
const wind_offshore_index = 15
const wind_onshore_index = 16
const solar_index = 17
const load_index = 18

data(d, i)::Vector{Float64} = d[i]["data"]

total_renewable(d) = data(d, wind_onshore_index) .+ data(d, wind_offshore_index) .+ data(d, solar_index)
total_load(d) = data(d, load_index)

function get_creator(; file="year_2023.json")
    d = load_data(file)
    creator(total_renewable(d), total_load(d), 0.25)
end

plot_feas(svs, Qmaxvs, r) = heatmap(svs, Qmaxvs, r;
    xlabel="Multiple of current renewable capacity", ylabel="Storage Capacity [mystery units]")

function draw_feasibility(creator, Qmax_inter, s_inter, NQmax, Ns; plot_res=false)
    res = zeros(Ns, NQmax)
    svs = range(s_inter[1], s_inter[2], Ns)
    Qmaxvs = range(Qmax_inter[1], Qmax_inter[2], NQmax)
    iter = collect(IterTools.product(enumerate(svs), enumerate(Qmaxvs)))
    Threads.@threads for ((i, s), (j, Qmax)) in iter
        @show Qmax s
        m = creator(Qmax, s)
        optimize!(m)
        if termination_status(m) == OPTIMAL
            res[i, j] = 1
        end
    end

    if plot_res
        display(plot_feas(svs, Qmaxvs, res))
    end

    return res, svs, Qmaxvs
end

function feas_fancy(creator, Qmax_inter, s_inter, NQmax, Ns; plot_res=false)
    ret = zeros(Ns)
    svs = range(s_inter[1], s_inter[2], Ns)
    Qmaxvs = range(Qmax_inter[1], Qmax_inter[2], NQmax)
    for (i, s) in enumerate(svs)
        @show s
        @memoize function is_feasible(qmax::Float64)
            @show s qmax
            m = creator(qmax, s)
            optimize!(m)
            return @show termination_status(m) == OPTIMAL
        end
        is_feasible(::Bool) = true
        ri = @show searchsortedfirst(Qmaxvs, true; by=is_feasible)
        ret[i] = ri <= NQmax ? Qmaxvs[ri] : NaN
    end

    return ret, svs
end

y,x = feas_fancy(get_creator(file="../year2023.json"), (1e6,1e7), (1,10), 10, 10; plot_res=true)

plot(x,y)
xlabel!("Multiple of current renewable production (MW)")
ylabel!("Storage Capacity [MWh]")
title!("Feasibility of storage for different renewable capacities (2023)")
savefig("feasibility.png")
