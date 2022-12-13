module AdventOfCode
export solve

using DataStructures
using InlineTest
using Reexport

@reexport using ReTest

# The days which have been solved
days = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]

# Generate lists of files and modules
dstrs = map(d -> "d" * lpad(d, 2, '0'), days)
jlfiles = map(d -> d * ".jl", dstrs)
inputfiles = map(d -> joinpath(@__DIR__, "..", "data", d * ".txt"), dstrs)
modules = map(Symbol, dstrs)

# Include all files import modules
foreach(include, jlfiles)
foreach(mod -> @eval(@reexport using .$mod), modules)

# Make lookup table of data and solve functions
inputlookup = Dict(days .=> inputfiles)
solvefnlookup = Dict(days .=> map(mod -> @eval($mod.solve), modules))

# Functions for solving
solve(d) = open(solvefnlookup[d], inputlookup[d])
solve() = OrderedDict(days .=> solve.(days))

end
