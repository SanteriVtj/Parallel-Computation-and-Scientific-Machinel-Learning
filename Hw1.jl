using Pkg
Pkg.activate("pcsciml")
using BenchmarkTools, InteractiveUtils, Statistics, StaticArrays, Plots, LaTeXStrings


function logistic_eq(x, r)
        r*x*(1-x)
end

function calc_attractor!(x₀, out, f, p, num_attract; warmup=400)
    @inbounds out[1] = x₀
    @inbounds for i in 1:(warmup+num_attract-1)
        if i > warmup
            out[i-warmup+1] = f(out[i-warmup], p)
        else
            out[1] = f(out[1], p)
        end
    end
    out
end

# function save_history()

x₀ = .25;
r = 2.9
num_attract = 150
out = Vector{typeof(x₀)}(undef, num_attract)
calc_attractor!(x₀, out, logistic_eq, r, num_attract)

@btime calc_attractor!(x₀, out, logistic_eq, r, num_attract)

@code_llvm calc_attractor!(x₀, out, logistic_eq, r, num_attract)

plot(out)


x = Vector{typeof(x₀)}(undef,0)
for i in 2.9:.001:4
    push!(x, calc_attractor!(x₀, out, logistic_eq, i, num_attract)...)
end
scatter(
    x,
    markercolor=:red,
    markerstrokecolor=:white,
    markerstrokewidth=0,
    markersize=2,
    markeralpha=.1,
    legend=false,
    xlabel='r',
    ylabel=L"x_{n+1}"
)
ylims!(0,1)

