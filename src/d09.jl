module d09

using Chain
using InlineTest

function moveh(h, d)
    if d == 'R'
        return (h[1] + 1, h[2])
    elseif d == 'L'
        return (h[1] - 1, h[2])
    elseif d == 'U'
        return (h[1], h[2] + 1)
    elseif d == 'D'
        return (h[1], h[2] - 1)
    else
        error("oops")
    end
end


istouching(h, t) = abs(h[1] - t[1]) <= 1 && abs(h[2] - t[2]) <= 1
movet(h, t) = istouching(h, t) ? t : t .+ clamp.((h .- t), Ref(-1:1))

function sim(d, l)
    r = fill((0, 0), l)
    visited = []
    for i in d
        for _ in 1:i[2]
            r[1] = moveh(r[1], i[1])
            for n in 2:length(r)
                r[n] = movet(r[n-1], r[n])
            end
            push!(visited, r[end])
        end
    end
    return length(unique(visited))
end

part1(d) = sim(d, 2)
part2(d) = sim(d, 10)

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            split(_, " ")
            (only(_[1]), parse(Int, _[2]))
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2
    """
const testarr = [
    ('R', 4),
    ('U', 4),
    ('L', 3),
    ('D', 1),
    ('R', 4),
    ('D', 1),
    ('L', 5),
    ('R', 2),
]
const teststr2 = """
    R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20
    """

@testset "d09" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 13
    @test part2(testarr) == 1
    @test part2(parseinput(IOBuffer(teststr2))) == 36
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
