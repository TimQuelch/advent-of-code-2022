module d13

using Base: nothing_sentinel
using Chain
using InlineTest

compare(t::Tuple)::Bool = compare(t[1], t[2])
function compare(l::AbstractVector, r::AbstractVector)::Bool
    return compareimpl(l, r)
end
function compareimpl(l::Number, r::Number)
    return l == r ? nothing : l < r
end
function compareimpl(l::Number, r::AbstractVector)
    # @info l, r
    compareimpl([l], r)
end
function compareimpl(l::AbstractVector, r::Number)
    # @info l, r
    compareimpl(l, [r])
end
function compareimpl(l::AbstractVector, r::AbstractVector)
    # @info l, r
    for (ln, rn) in zip(l, r)
        c = compareimpl(ln, rn)
        if !isnothing(c)
            return c
        end
    end
    if length(l) == length(r)
        return nothing
    else
        return length(l) < length(r)
    end
end

function part1(d)
    d = deepcopy(d)
    correct = map(compare, d)
    indices = findall(correct)
    return sum(indices)
end

function sortpackets(d)
    d = deepcopy(d)
    packets = collect(Iterators.flatten((Iterators.flatten(d), ([[2]], [[6]]))))
    sort!(packets, lt=compare)
    return packets
end

function part2(d)
    d = deepcopy(d)
    sorted = sortpackets(d)
    return prod(findall(p -> p == [[2]] || p == [[6]], sorted))
end

function parseinput(io)
    @chain io begin
        read(_, String)
        strip
        split(_, "\n\n")
        map(_) do e
            one, two = split.(e, '\n')
            return (eval(Meta.parse(one)), eval(Meta.parse(two)))
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    [1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]
    """
const testarr = [
    ([1,1,3,1,1],
    [1,1,5,1,1])

    ([[1],[2,3,4]],
    [[1],4]
)
    ([9],
    [[8,7,6]])

    ([[4,4],4,4],
    [[4,4],4,4,4])

    ([7,7,7,7],
    [7,7,7]
)
    ([],
    [3])

    ([[[]]],
    [[]])

    ([1,[2,[3,[4,[5,6,7]]]],8,9],
    [1,[2,[3,[4,[5,6,0]]]],8,9])
]

const test2res = [[],
[[]],
[[[]]],
[1,1,3,1,1],
[1,1,5,1,1],
[[1],[2,3,4]],
[1,[2,[3,[4,[5,6,0]]]],8,9],
[1,[2,[3,[4,[5,6,7]]]],8,9],
[[1],4],
[[2]],
[3],
[[4,4],4,4],
[[4,4],4,4,4],
[[6]],
[7,7,7],
[7,7,7,7],
[[8,7,6]],
[9],]


@testset "d13" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 13
    @test sortpackets(testarr) == test2res
    @test part2(testarr) == 140
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
