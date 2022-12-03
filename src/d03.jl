module d03

using Chain
using InlineTest

# Abuse ASCII to map characters to values. In ASCII A-Z precedes a-z order
function priority(c::Char)
    @assert c >= 'A' && c <= 'z'
    if c >= 'a'
        return c - 'a' + 1
    else
        return c - 'A' + 27
    end
end

function part1(d)
    s = map(d) do x
        @chain x begin
            Iterators.partition(_, div(length(x), 2))
            intersect(_...)
            only
            priority
        end
    end
    return sum(s)
end

function part2(d)
    s = map(Iterators.partition(d, 3)) do x
        @chain x begin
            intersect(_...)
            only
            priority
        end
    end
    return sum(s)
end

function parseinput(io)
    collect(eachline(io))
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw
    """
const testarr = [
    "vJrwpWtwJgWrhcsFMMfFFhFp"
    "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL"
    "PmmdzqPrVvPwwTWBwg"
    "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn"
    "ttgJtRGJQctTZtZT"
    "CrZsJsPPZsGzwwsLwLmpwMDw"
]

@testset "d03" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test priority('a') == 1
    @test priority('A') == 27
    @test priority('z') == 26
    @test priority('Z') == 52
    @test part1(testarr) == 157
    @test part2(testarr) == 70
    @test solve(IOBuffer(teststr)) == (157, 70)
end

end
