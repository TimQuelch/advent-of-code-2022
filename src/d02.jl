module d02

using Chain
using InlineTest

# This one is quite ugly. I'm not happy with this solution

valuelookup = Dict(
    "X" => 1,
    "Y" => 2,
    "Z" => 3
)

matchlookup = Dict(
    "A" => "X",
    "B" => "Y",
    "C" => "Z",
)

drawlookup = Dict(
    "A" => (other) -> other == "X",
    "B" => (other) -> other == "Y",
    "C" => (other) -> other == "Z",
)

winlookup = Dict(
    "A" => (other) -> other == "Y",
    "B" => (other) -> other == "Z",
    "C" => (other) -> other == "X",
)

function game(a, b)
    if drawlookup[a](b)
        return 3
    elseif winlookup[a](b)
        return 6
    else
        return 0
    end
end

p2winlookup = Dict(
    "A" => 2,
    "B" => 3,
    "C" => 1,
)
p2drawlookup = Dict(
    "A" => 1,
    "B" => 2,
    "C" => 3,
)
p2loselookup = Dict(
    "A" => 3,
    "B" => 1,
    "C" => 2,
)

function part1(d)
    s = map(d) do p
        game(p[1], p[2]) + valuelookup[p[2]]
    end
    return sum(s)
end

function part2(d)
    s = map(d) do p
        if p[2] == "X"
            return 0 + p2loselookup[p[1]]
        elseif p[2] == "Y"
            return 3 + p2drawlookup[p[1]]
        else
            return 6 + p2winlookup[p[1]]
        end
    end
    return sum(s)
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            split(_, " ")
            (_[1], _[2])
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    A Y
    B X
    C Z
    """
const testarr = [
    ("A", "Y"),
    ("B", "X"),
    ("C", "Z")
]

@testset "d02" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 15
    @test part2(testarr) == 12
    @test solve(IOBuffer(teststr)) == (15, 12)
end

end
