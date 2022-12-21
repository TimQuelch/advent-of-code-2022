module d20

using Chain
using InlineTest

function mix(d, key, n)
    ns = d .* key
    is = collect(eachindex(ns))

    for i in repeat(is, n)
        # Find and remove index of i in is
        j = findfirst(==(i), is)
        popat!(is, j)           # Result is i, we ignore

        insert!(is, mod1(j + ns[i], length(is)), i)
    end

    zni = findfirst(==(0), ns)  # Index of 0 in original
    zi = findfirst(==(zni), is) # Index of 0 in rearranged indices

    vals = map((1000, 2000, 3000)) do i
        ns[is[mod1(zi + i, length(ns))]]
    end
    return sum(vals)
end

function part1(d)
    return mix(d, 1, 1)
end

function part2(d)
    return mix(d, 811589153, 10)
end

function parseinput(io)
    map(eachline(io)) do l
        parse(Int, l)
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    1
    2
    -3
    3
    -2
    0
    4
    """
const testarr = [
    1
    2
    -3
    3
    -2
    0
    4
]

@testset "d20" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 3
    @test part2(testarr) == 1623178306
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
