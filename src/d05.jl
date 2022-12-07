module d05

using Chain
using InlineTest

function part1(d)
    s, is = deepcopy.(d)
    for i in is
        for _ in 1:i[1]
            c = pop!(s[i[2]])
            push!(s[i[3]], c)

        end
    end
    return String([stack[end] for stack in s])
end

function part2(d)
    s, is = deepcopy.(d)
    for i in is
        cs = []
        for _ in 1:i[1]
            c = pop!(s[i[2]])
            push!(cs, c)
        end
        append!(s[i[3]], reverse(cs))
    end
    return String([stack[end] for stack in s])
end

function parseinput(io)
    s = read(io, String)
    stacksin, instructions = split(s, "\n\n")
    stacksin = split(stacksin, '\n')[1:end-1]
    maxlen = maximum(length, stacksin)
    padded = rpad.(stacksin, maxlen, " ")
    array = reduce(hcat, collect.(padded))
    size(array)
    stacks = array[2:4:end, :]
    tidied = map(eachrow(stacks)) do x
        collect(Iterators.reverse(filter(c -> c != ' ', x)))
    end

    instructions = map(split(strip(instructions), '\n')) do l
        m = match(r"move ([0-9]+) from ([0-9]+) to ([0-9]+)", l)
        return (parse(Int, m[1]), parse(Int, m[2]), parse(Int, m[3]))
    end
    return tidied, instructions
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
        [D]
    [N] [C]
    [Z] [M] [P]
    1   2   3

    move 1 from 2 to 1
    move 3 from 1 to 3
    move 2 from 2 to 1
    move 1 from 1 to 2
    """
const testarr = (
    [['Z', 'N'],
      ['M', 'C', 'D'],
      ['P']],
    [(1, 2, 1),
    (3, 1, 3),
    (2, 2, 1),
    (1, 1, 2)],
)

@testset "d05" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == "CMZ"
    @test part2(testarr) == "MCD"
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
