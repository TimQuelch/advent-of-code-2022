module d08

using Chain
using InlineTest

function part1(d)
    w, h = size(d)
    outer = 2 * w + 2 * (h - 2)
    inner = 0
    for i in 2:(w-1)
        for j in 2:(h-1)
            v = d[i, j]
            if any([
                all(<(v), d[begin:i-1, j]),
                all(<(v), d[i+1:end, j]),
                all(<(v), d[i, begin:j-1]),
                all(<(v), d[i, j+1:end]),
            ])
                inner = inner + 1
            end
        end
    end
    return inner + outer
end

function distscore(v, a)
    i = findfirst(>=(v), a)
    return isnothing(i) ? length(a) : i
end

function part2(d)
    w, h = size(d)
    best = 0
    for i in 2:(w-1)
        for j in 2:(h-1)
            v = d[i, j]
            score = prod(map(a -> distscore(v, a), [
                reverse(d[begin:i-1, j]),
                d[i+1:end, j],
                reverse(d[i, begin:j-1]),
                d[i, j+1:end],
            ]))

            best = max(best, score)

        end
    end
    return best
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        @chain l begin
            collect
            parse.(Int, _)
            Vector(_)'
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    30373
    25512
    65332
    33549
    35390
    """
const testarr = [
    3 0 3 7 3
    2 5 5 1 2
    6 5 3 3 2
    3 3 5 4 9
    3 5 3 9 0
]

@testset "d08" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 21
    @test part2(testarr) == 8
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
