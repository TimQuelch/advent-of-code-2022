module d23

using Chain
using InlineTest
using OffsetArrays
using Base.Iterators

northnb(c) = map(x -> c .+ x, ((-1, -1), (-1, 0), (-1, 1)))
southnb(c) = map(x -> c .+ x, ((1, -1), (1, 0), (1, 1)))
eastnb(c) = map(x -> c .+ x, ((-1, 1), (0, 1), (1, 1)))
westnb(c) = map(x -> c .+ x, ((-1, -1), (0, -1), (1, -1)))
nb(c) = map(x -> c .+ x, ((-1, -1), (-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1)))

const movements = (
    (northnb, (-1, 0)),
    (southnb, (1, 0)),
    (westnb, (0, -1)),
    (eastnb, (0, 1)),
)

function bbox(es)
    xmin, xmax = extrema(e -> e[1], es)
    ymin, ymax = extrema(e -> e[2], es)
    return (xmin, xmax), (ymin, ymax)
end

function display(es)
    ((xmin, xmax), (ymin, ymax)) = bbox(es)
    a = OffsetArray(falses(xmax - xmin + 1, ymax - ymin + 1), xmin:xmax, ymin:ymax)

    screen = OffsetArray(fill('.', xmax - xmin + 1, ymax - ymin + 1), xmin:xmax, ymin:ymax)
    screen[CartesianIndex.(es)] .= '#'
    return @chain screen begin
	    map(String, eachrow(_))
        join(_, '\n')
    end
end

function sim(d, N=10)
    es = Tuple.(findall(d))

    if isnothing(N)
        N = typemax(Int)
    end

    n = 1
    while n <= N
        proposed = map(collect(es)) do e
            if !any(nb -> nb ∈ es, nb(e))
                return e
            end
            for (dnb, dir) in @chain movements cycle drop(n-1) take(4)
                if !any(nb -> nb ∈ es, dnb(e))
                    return e .+ dir
                end
            end
            return e
        end

        moved = map(collect(es), proposed) do e, p
            return count(==(p), proposed) < 2 ? p : e
        end
        @assert length(unique(es)) == length(es)
        moved = Set(moved)
        if es == moved
            break
        end
        es = moved
        n += 1
    end

    return es, n
end

function part1(d)
    es, _ = sim(d, 10)
    ((xmin, xmax), (ymin, ymax)) = bbox(es)
    return (xmax - xmin + 1) * (ymax - ymin + 1) - length(es)
end

function part2(d)
    sim(d, nothing)[2]
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

const teststr2 = """
    ..##.
    ..#..
    .....
    ..##.
    .....
    """

@testset "d23" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 110
    @test part2(testarr) == 20
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
