module d01

using Chain
using InlineTest

part1(d) = maximum(map(sum, d))
part2(d) = sum(sort(map(sum, d))[end-2:end])

function parseinput(io)
    @chain io begin
        read(_, String)
        strip
        split(_, "\n\n")
        map(_) do e
            parse.(Int, split(e, "\n"))
        end
    end
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    1000
    2000
    3000

    4000

    5000
    6000

    7000
    8000
    9000

    10000
"""
const testarr = [
    [1000, 2000, 3000],
    [4000],
    [5000, 6000],
    [7000, 8000, 9000],
    [10000]
]

@testset "d01" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 24000
    @test part2(testarr) == 45000
    @test solve(IOBuffer(teststr)) == (24000, 45000)
end

end
