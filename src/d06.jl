module d06

using Chain
using InlineTest

function part1(d)
    for i in 4:length(d)
        if length(unique(d[i-3:i])) == 4
            return i
        end
    end
end

function part2(d)
    for i in 14:length(d)
        if length(unique(d[i-13:i])) == 14
            return i
        end
    end
end

function parseinput(io)
    read(io, String)
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """mjqjpqmgbljsphdztnvjfqwrcgsmlb"""
const testarr = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"

@testset "d06" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 7
    @test part2(testarr) == 19
    @test solve(IOBuffer(teststr)) == (7, 19)
end

end
