module d11

using Chain
using InlineTest

function sim(d, modifierfn, nrounds)
    monkeys = deepcopy(d)
    inspected = zeros(Int, size(monkeys))
    for _ in 1:nrounds
        for (n, m) in enumerate(monkeys)
            while !isempty(m.items)
                inspected[n] = inspected[n] + 1
                i = popfirst!(m.items)
                # invokelatest needed for world age issues for evalled fns
                w = Base.@invokelatest m.operation(i)
                w = modifierfn(w)
                new = w % m.divisor == 0 ? m.true_index : m.false_index
                push!(monkeys[new+1].items, w)
            end
        end
    end
    return prod(sort(inspected)[end-1:end])
end

function part1(d)
    return sim(d, w -> div(w, 3), 20)
end

function part2(d)
    lcmdivisor = mapreduce(m -> m.divisor, lcm, d)
    return sim(d, w -> w % lcmdivisor, 10000)
end

function parseinput(io)
    @chain io begin
        read(_, String)
        strip
        split(_, "\n\n")
        map(_) do e
            m = match(r"Starting items: ([0-9, ]+)", e)
            starting = parse.(Int, split(m[1], ", "))

            m = match(r"Operation: new = (.+)\n", e)
            operation = @eval old -> $(Meta.parse(m[1]))

            m = match(r"divisible by ([0-9]+)", e)
            divisor = parse(Int, m[1])

            m = match(r"If true: throw to monkey ([0-9]+)", e)
            true_index = parse(Int, m[1])

            m = match(r"If false: throw to monkey ([0-9]+)", e)
            false_index = parse(Int, m[1])
            return Monkey(starting, operation, divisor, true_index, false_index)
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

struct Monkey
    items::Vector{Int}
    operation::Function
    divisor::Int
    true_index::Int
    false_index::Int
end

function Base.:(==)(a::Monkey, b::Monkey)
    f = (:items, :divisor, :true_index, :false_index)
    getfield.(Ref(a), f) == getfield.(Ref(b), f)
end

const teststr = """
    Monkey 0:
    Starting items: 79, 98
    Operation: new = old * 19
    Test: divisible by 23
        If true: throw to monkey 2
        If false: throw to monkey 3

    Monkey 1:
    Starting items: 54, 65, 75, 74
    Operation: new = old + 6
    Test: divisible by 19
        If true: throw to monkey 2
        If false: throw to monkey 0

    Monkey 2:
    Starting items: 79, 60, 97
    Operation: new = old * old
    Test: divisible by 13
        If true: throw to monkey 1
        If false: throw to monkey 3

    Monkey 3:
    Starting items: 74
    Operation: new = old + 3
    Test: divisible by 17
        If true: throw to monkey 0
        If false: throw to monkey 1
    """
const testarr = [
    Monkey([79, 98], old -> old * 19, 23, 2, 3),
    Monkey([54, 65, 75, 74], old -> old + 6, 19, 2, 0),
    Monkey([79, 60, 97], old -> old * old, 13, 1, 3),
    Monkey([74], old -> old + 3, 17, 0, 1),
]

@testset "d11" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 10605
    @test part2(testarr) == 2713310158
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
