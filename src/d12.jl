module d12

using Chain
using InlineTest
using Graphs

# Get the linear indices of the cartesian neighbours of a node in 2D array
function neighbours(d, i)
    neighbours = (CartesianIndices(d)[i],) .+ CartesianIndex.([(1, 0), (0, 1), (-1, 0), (0,-1)])
    neighbours = filter(n -> checkbounds(Bool, d, n), neighbours)
    return map(i -> LinearIndices(d)[i], neighbours)
end

# This builds the directed graph in the reverse direction (i.e a forward edge from a -> b indicates
# the hiker can step from b to a). Originally for part 1 I had the edges directed the other way,
# however on tidying up it is simpler to keep the one generator to build the inverse graph
function build_transpose_graph(d)
    edges::Vector{Tuple{Int, Int}} = []
    for node in eachindex(d)
        ns = neighbours(d, node)
        ns = filter(n -> d[node] + 1 >= d[n],  ns)
        append!(edges, tuple.(ns, node))
    end
    g = Graphs.SimpleDiGraph(Edge.(edges))
    # @show nv(g), ne(g)
    return g
end

function part1(d)
    d = deepcopy(d)
    start = findfirst(==('S'), d[:])
    finish = findfirst(==('E'), d[:])
    d[d .== 'S'] .= 'a'
    d[d .== 'E'] .= 'z'
    g = build_transpose_graph(d)
    # Note we are starting at the finish because the graph is transposed
    res = Graphs.dijkstra_shortest_paths(g, finish)
    return res.dists[start]
end

function part2(d)
    d = deepcopy(d)
    d[d .== 'S'] .= 'a'
    starts = findall(==('a'), d[:])
    finish = findfirst(==('E'), d[:])
    d[d .== 'E'] .= 'z'
    g = build_transpose_graph(d)
    # Note we are starting at the finish because the graph is transposed
    res = Graphs.dijkstra_shortest_paths(g, finish)
    # Get the minimum of the shortest distances to all the 'a' nodes
    return res.dists[starts] |> minimum
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            collect
            Vector
            reshape(_, 1, :)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi
    """
const testarr = [
    'S' 'a' 'b' 'q' 'p' 'o' 'n' 'm'
    'a' 'b' 'c' 'r' 'y' 'x' 'x' 'l'
    'a' 'c' 'c' 's' 'z' 'E' 'x' 'k'
    'a' 'c' 'c' 't' 'u' 'v' 'w' 'j'
    'a' 'b' 'd' 'e' 'f' 'g' 'h' 'i'
]

@testset "d12" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 31
    @test part2(testarr) == 29
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
