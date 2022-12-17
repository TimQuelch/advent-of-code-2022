module d16

using Chain
using InlineTest
using Graphs
using DataStructures

struct Valve
    name::String
    flowrate::Int
end

struct State
    current_loc::Int
    turned_on::BitSet
    current_time::Int
end

vindex(valves, valve::Valve) = findfirst(==(valve), valves)
vindex(valves, name::AbstractString) = findfirst(v -> v.name == name, valves)

function build_graph(d)
    valves = map(d) do valve
        Valve(valve[1], valve[2])
    end
    g = SimpleGraph(length(valves))
    for valve in d
        for t in valve[3]
            add_edge!(g, vindex(valves, valve[1]), vindex(valves, t))
        end
    end
    return g, valves
end

function sim(d, time_available)
    g, valves = build_graph(d)
    required = filter(v -> v.flowrate > 0 || v.name == "AA", valves)
    requiredindices = vindex.(Ref(valves), required)

    distmx = Array{Int}(undef, length(required), length(required))
    for (i, reqi) in enumerate(requiredindices)
        res = dijkstra_shortest_paths(g, reqi)
        distmx[i, :] .= res.dists[requiredindices]
    end

    queue = Queue{Tuple{State, Int}}()
    bestvalue = DefaultDict{State, Int}(-1)

    function maybe_add(state::State, value)
        if value > bestvalue[state] && state.current_time > 0
            enqueue!(queue, (state, value))
            bestvalue[state] = value
        end
    end

    maybe_add(State(vindex(valves, "AA"), BitSet([vindex(valves, "AA")]), time_available), 0)

    while !isempty(queue)
        state, value = dequeue!(queue)
        # Add path if we turn it on
        if state.current_loc ∉ state.turned_on && state.current_time > 0
            newstate = State(state.current_loc, BitSet([state.turned_on..., state.current_loc]), state.current_time - 1)
            maybe_add(newstate, value + newstate.current_time * valves[newstate.current_loc].flowrate)
        end
        # Add paths for all remaining valves to turn on
        for i in setdiff(requiredindices, state.turned_on)
            dist = distmx[findfirst(==(state.current_loc), requiredindices), findfirst(==(i), requiredindices)]
            if dist < state.current_time
                newstate = State(i, state.turned_on, state.current_time - dist)
                maybe_add(newstate, value)
            end
        end
    end

    return bestvalue
end

function part1(d)
    return sim(d, 30) |> values |> maximum
end

function part2(d)
    values = sim(d, 26)

    best = DefaultDict{BitSet, Int}(-1)
    for e in values
        best[e[1].turned_on] = max(best[e[1].turned_on], e[2])
    end

    return @chain best begin
        Iterators.product(_, _)
	    Iterators.filter(x -> length(intersect(x[1][1], x[2][1])) == 1, _)
        Iterators.map(x -> x[1][2] + x[2][2], _)
        maximum
    end
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        m = match(r"Valve ([A-Z]+) has flow rate=([0-9]+); tunnel(s)? lead(s)? to valve(s)? ([A-Z, ]+)$", l)
        return (m[1], parse(Int, m[2]), collect(split(m[6], ", ")))
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II
    """
const testarr = [
    ("AA", 0 ,  ["DD", "II", "BB"]),
    ("BB", 13,  ["CC", "AA"]),
    ("CC", 2 ,  ["DD", "BB"]),
    ("DD", 20,  ["CC", "AA", "EE"]),
    ("EE", 3 ,  ["FF", "DD"]),
    ("FF", 0 ,  ["EE", "GG"]),
    ("GG", 0 ,  ["FF", "HH"]),
    ("HH", 22,  ["GG"]),
    ("II", 0 ,  ["AA", "JJ"]),
    ("JJ", 21,  ["II"]),
]

testgraph() = build_graph(testarr)

@testset "d16" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test nv(testgraph()[1]) == 10
    @test ne(testgraph()[1]) == 10
    @test part1(testarr) == 1651
    @test part2(testarr) == 1707
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
