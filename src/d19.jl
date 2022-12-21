module d19

using Chain
using InlineTest
using DataStructures
using Distributed

struct StateVec
    ore::Int16
    clay::Int16
    obsidian::Int16
    geode::Int16
end

Base.convert(::Type{StateVec}, x::AbstractArray) = StateVec(x...)
Base.convert(::Type{StateVec}, x::Tuple) = StateVec(x...)
# Base.convert(::Type{Tuple}, x::StateVec) = tuple(x...)
# Base.convert(::Type{Tuple}, x::AbstractArray) = [x...]

Base.show(io::IO, x::StateVec) = print(io, "($(x.ore), $(x.clay), $(x.obsidian), $(x.geode))")

function Base.:(==)(a::StateVec, b::StateVec)
    f = (:ore, :clay, :obsidian, :geode)
    getfield.(Ref(a), f) == getfield.(Ref(b), f)
end

Base.iterate(a::StateVec) = (a.ore, Val(1))
Base.iterate(a::StateVec, ::Val{1}) = (a.clay, Val(2))
Base.iterate(a::StateVec, ::Val{2}) = (a.obsidian, Val(3))
Base.iterate(a::StateVec, ::Val{3}) = (a.geode, Val(4))
Base.iterate(::StateVec, ::Val{4}) = nothing
Base.length(::StateVec) = 4

struct Blueprint
    id::Int
    recipes::Vector{Tuple{StateVec,StateVec}}
end

function Base.:(==)(a::Blueprint, b::Blueprint)
    f = (:id, :recipes)
    getfield.(Ref(a), f) == getfield.(Ref(b), f)
end

can_afford(s::StateVec, c::StateVec) = all(>=(0), s .- c)

function building_below_max(producing::StateVec, built::StateVec, maxes::StateVec)
    all(<=(0), (producing .+ built .- maxes))
end

current_value(current, producing, t) = current.geode + t * producing.geode
best_possible(current, producing, t) = current_value(current, producing, t) + sum(t:-1:1)

trunc_state(c, p) = (c.ore, c.clay, c.obsidian, p.ore, p.clay, p.obsidian)

function sim(blueprint::Blueprint, time)

    blueprint = deepcopy(blueprint)

    init_state = (StateVec(0, 0, 0, 0), StateVec(1, 0, 0, 0))

    queue = Vector{Tuple{StateVec, StateVec}}()
    push!(queue, init_state)

    max_cost = @chain blueprint begin
        map(r -> r[1], _.recipes)
        reduce(_, init=StateVec(0, 0, 0, 0)) do a::StateVec, b::StateVec
            StateVec(
                map(max, a, b)...
            )
        end
    end

    function prune_queue(queue, t)
        best_current = @chain begin
            queue
            map(cp -> current_value(cp..., t), _)
            maximum
        end

        best = DefaultDict{NTuple{6, Int16}, Int}(-1)
        for (current, producing) in queue
            s = trunc_state(current, producing)
            value = current_value(current, producing, t)
            best[s] = max(best[s], value)
        end

        pruned = @chain queue begin
            Iterators.filter(cp -> all(>=(0), (max_cost .- cp[2])[1:3]), _)
            Iterators.filter(cp -> best_possible(cp[1], cp[2], t) >= best_current, _)
            Iterators.filter(cp -> best[trunc_state(cp...)] <= current_value(cp..., t), _)
            unique(cp -> trunc_state(cp...), _)
            sort!(_, by=cp -> cp[1] .+ 2 .* cp[2], lt=(a, b) -> reverse(a) < reverse(b), rev=true)
            Iterators.take(_, 3000)
            collect
        end

        return pruned, best_current
    end


    for t in time-1:-1:0
        oldlength = length(queue)
        queue, best = prune_queue(queue, t)
        # @info "Time $(time - t)" length(queue) oldlength (oldlength - length(queue)) best
        next_queue = Vector{Tuple{StateVec, StateVec}}()

        while !isempty(queue)
            current, producing = pop!(queue)

            for (cost, produced) in blueprint.recipes
                if can_afford(current, cost)
                    new_state = (current .+ producing .- cost, producing .+ produced)
                    push!(next_queue, new_state)
                end
            end
            new_state = (current .+ producing, producing)
            push!(next_queue, new_state)
        end

        queue = next_queue
    end

    res = maximum(cp -> cp[1].geode, queue)
    return res
end

function part1(d)
    mapfn = (nworkers() == 1) ? map : pmap
    ql = mapfn(b -> sim(b, 24) * b.id, d)
    return sum(ql)
end

function part2(d)
    mapfn = (nworkers() == 1) ? map : pmap
    ql = mapfn(b -> sim(b, 32), Iterators.take(d, 3))
    return prod(ql)
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        m = match(r"Blueprint ([0-9]+): Each ore robot costs ([0-9]+) ore. Each clay robot costs ([0-9]+) ore. Each obsidian robot costs ([0-9]+) ore and ([0-9]+) clay. Each geode robot costs ([0-9]+) ore and ([0-9]+) obsidian.", l)
        is = parse.(Int, m)
        return Blueprint(
            is[1],
            [
                ((is[2], 0, 0, 0), (1, 0, 0, 0)),
                ((is[3], 0, 0, 0), (0, 1, 0, 0)),
                ((is[4], is[5], 0, 0), (0, 0, 1, 0)),
                ((is[6], 0, is[7], 0), (0, 0, 0, 1)),
            ]
        )
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
    Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
"""
const testarr = [
    # Blueprint(1, Cost(4, 0, 0), Cost(2, 0, 0), Cost(3, 14, 0), Cost(2, 0, 7)),
    # Blueprint(2, Cost(2, 0, 0), Cost(3, 0, 0), Cost(3, 8, 0), Cost(3, 0, 12))
    Blueprint(1, [
                ((4, 0, 0, 0), (1, 0, 0, 0)),
                ((2, 0, 0, 0), (0, 1, 0, 0)),
                ((3, 14, 0, 0), (0, 0, 1, 0)),
                ((2, 0, 7, 0), (0, 0, 0, 1)),
            ]),
    Blueprint(2, [
                ((2, 0, 0, 0), (1, 0, 0, 0)),
                ((3, 0, 0, 0), (0, 1, 0, 0)),
                ((3, 8, 0, 0), (0, 0, 1, 0)),
                ((3, 0, 12, 0), (0, 0, 0, 1)),
            ]),
]

@testset "d19" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 33
    @test part2(testarr) == 56 * 62
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
