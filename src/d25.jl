module d25

using Chain
using InlineTest

const from = Dict(
    '2' => 2,
    '1' => 1,
    '0' => 0,
    '-' => -1,
    '=' => -2,
)
const to = Dict(values(from) .=> keys(from))

function from_snafu(s)
    @chain begin
        s
        collect
        map(c -> from[c], _)
        reverse
        enumerate
        map((iv) -> 5^(iv[1] - 1) * iv[2], _)
        sum
    end
end
function to_snafu(d)
    v = d
    e = 0
    sn = Int8[]
    while v > 0
        rem = ((v + 2) % 5) - 2
        push!(sn, rem)
        v -= rem
        v = div(v, 5)
    end

    return @chain begin
        sn
        map(d -> to[d], _)
        reverse
        String
    end
end

function part1(d)
    return @chain begin
        d
        map(from_snafu, _)
        sum
        to_snafu
    end
end

function parseinput(io)
    collect(eachline(io))
end

solve(v) = (part1(v), nothing)
solve(io::IO) = solve(parseinput(io))

const teststr = """
    1=-0-2
    12111
    2=0=
    21
    2=01
    111
    20012
    112
    1=-1=
    1-12
    12
    1=
    122
    """
const testarr = [
    "1=-0-2",
    "12111",
    "2=0=",
    "21",
    "2=01",
    "111",
    "20012",
    "112",
    "1=-1=",
    "1-12",
    "12",
    "1=",
    "122",
]

const testlookup = [
    (1,  "1"),
    (2,  "2"),
    (3,  "1="),
    (4,  "1-"),
    (5,  "10"),
    (6,  "11"),
    (7,  "12"),
    (8,  "2="),
    (9,  "2-"),
    (10,  "20"),
    (15,  "1=0"),
    (20,  "1-0"),
    (2022,  "1=11-2"),
    (12345,  "1-0---0"),
    (314159265,  "1121-1110-1=0"),
]

@testset "d25" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    for (d, s) in testlookup
        @test from_snafu(s) == d
    end
    for (d, s) in testlookup
        @test to_snafu(d) == s
    end
    @test part1(testarr) == "2=-1=0"
    # @test part2(testarr) == nothing
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
