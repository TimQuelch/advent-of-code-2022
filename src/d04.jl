module d04

using Chain
using InlineTest

function part1(d)
    return count(d) do r
        a, b = r
        return (a[1] >= b[1] && a[2] <= b[2]) || (b[1] >= a[1] && b[2] <= a[2])
    end
end

function part2(d)
    return count(d) do r
        a, b = r
        return a[1] <= b[2] && a[2] >= b[1]
    end
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            match(r"([0-9]+)-([0-9]+),([0-9]+)-([0-9]+)", _)
            parse.(Int, _)
            @aside @assert _[1] <= _[2] && _[3] <= _[4] # Sanity check
            ((_[1], _[2]), (_[3], _[4]))
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    """
const testarr = [
    ((2, 4), (6, 8)),
    ((2, 3), (4, 5)),
    ((5, 7), (7, 9)),
    ((2, 8), (3, 7)),
    ((6, 6), (4, 6)),
    ((2, 6), (4, 8)),
]

@testset "d04" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 2
    @test part2(testarr) == 4
    @test solve(IOBuffer(teststr)) == (2, 4)
end

end
