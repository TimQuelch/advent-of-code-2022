module d23

using Chain
using InlineTest

northnb(c) = map(x -> c .+ x, ((-1, 1), (0, 1), (1, 1)))
southnb(c) = map(x -> c .+ x, ((-1, -1), (0, -1), (1, -1)))
eastnb(c) = map(x -> c .+ x, ((1, -1), (1, 0), (1, 1)))
westnb(c) = map(x -> c .+ x, ((-1, -1), (-1, 0), (-1, 1)))
nb(c) = map(x -> c .+ x, ((-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1), (-1, -1), (-1, 0)))

function part1(d)
    @show es = Tuple.(findall(d))
    N = 10

    for dnb in Iterators.take(Iterators.cycle((northnb, southnb, eastnb, westnb)), N)
        nonmoving = filter(es) do e
            nbs = nb(e)
            return any(nb -> nb ∈ e, nbs)
        end
    end
end

function part2(d)
    nothing
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            collect
            map(==('#'), _)
            Vector{Bool}(_)
            reshape(_, 1, :)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    ....#..
    ..###.#
    #...#.#
    .#...##
    #.###..
    ##.#.##
    .#..#..
    """
const testarr = Bool[
    0 0 0 0 1 0 0
    0 0 1 1 1 0 1
    1 0 0 0 1 0 1
    0 1 0 0 0 1 1
    1 0 1 1 1 0 0
    1 1 0 1 0 1 1
    0 1 0 0 1 0 0
]

@testset "d23" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 110
    # @test part2(testarr) == nothing
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
