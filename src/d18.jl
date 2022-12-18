module d18

using Chain
using InlineTest
using Graphs

is_neighbour(a, b) = sum(abs.(a .- b)) == 1

function bbox(d)
    xx = extrema(p -> p[1], d)
    yy = extrema(p -> p[2], d)
    zz = extrema(p -> p[3], d)
    return (xx .+ (-1, 1), yy .+ (-1, 1), zz .+ (-1, 1))
end

# Build a graph of the empty voxels
function build_graph(d)
    xx, yy, zz = bbox(d)
    vs = setdiff(Iterators.product(xx[1]:xx[2], yy[1]:yy[2], zz[1]:zz[2]), d)
    g = SimpleGraph(length(vs))
    dirs = [(1, 0, 0), (0, 1, 0), (0, 0, 1), (-1, 0, 0), (0, -1, 0), (0, 0, -1)]
    for (i, v) in enumerate(vs)
        neighbours = @chain begin
            dirs
            map(dir -> v .+ dir, _)
            filter(in(vs), _)
        end
        for n in neighbours
            j = findfirst(==(n), vs)
            add_edge!(g, Edge(i, j))
        end
    end
    return g, vs
end

function surface_area(ps)
    total = 6 * length(ps)
    neighbours = map(ps) do a
        count(b -> is_neighbour(a, b), ps)
    end
    return total - sum(neighbours)
end

function part1(d)
    return surface_area(d)
end

function part2(d)
    g, vs = build_graph(d)

    return @chain begin
	    g
        connected_components(_)
        sort!(_, by=length)     # Largest connected component is the exterior void
        _[begin:end-1]          # We want to ignore it
        map(c -> map(p -> vs[p], c), _) # Vertex index to points
        map(surface_area, _)            # Calculate SA of interior voids
        surface_area(d) - sum(_)        # Subtract SA of interior from total
    end
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(_, ',')
            parse.(Int, _)
            tuple(_...)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    2,2,2
    1,2,2
    3,2,2
    2,1,2
    2,3,2
    2,2,1
    2,2,3
    2,2,4
    2,2,6
    1,2,5
    3,2,5
    2,1,5
    2,3,5
    """
const testarr = [
    (2, 2, 2),
    (1, 2, 2),
    (3, 2, 2),
    (2, 1, 2),
    (2, 3, 2),
    (2, 2, 1),
    (2, 2, 3),
    (2, 2, 4),
    (2, 2, 6),
    (1, 2, 5),
    (3, 2, 5),
    (2, 1, 5),
    (2, 3, 5),
]

@testset "d18" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 64
    @test part2(testarr) == 58
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
