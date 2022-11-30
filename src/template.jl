module DAYCODE

using Chain
using InlineTest

part1(d) = nothing
part2(d) = nothing

parseinput(io) = mapreduce(vcat, eachline(io)) do l
    @chain l begin
        l
    end
end
solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    """
const testarr = [
]

@testset "DAYCODE" begin
    # @test parseinput(IOBuffer(teststr)) == testarr
    # @test part1(testarr) == nothing
    # @test part2(testarr) == nothing
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
