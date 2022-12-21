module d21

using Chain
using InlineTest

struct Op
    l::String
    op::Char
    r::String
end

const forwardops = Dict(
    '+' => (l, r) -> l + r,
    '-' => (l, r) -> l - r,
    '*' => (l, r) -> l * r,
    '/' => (l, r) -> div(l, r)
)
const linvops = Dict(
    '+' => (x, r) -> x - r,
    '-' => (x, r) -> x + r,
    '*' => (x, r) -> div(x, r),
    '/' => (x, r) -> x * r
)
const rinvops = Dict(
    '+' => (l, x) -> x - l,
    '-' => (l, x) -> l - x,
    '*' => (l, x) -> div(x, l),
    '/' => (l, x) -> div(l, x),
)

resolve(m::String, d::Dict) = resolve(d[m], d)
resolve(m::Number, ::Dict) = m

function resolve(m::Op, d::Dict)
    l = resolve(m.l, d)
    r = resolve(m.r, d)
    return forwardops[m.op](l, r)
end

contains_nothing(m::Nothing, d) = true
contains_nothing(m::Number, d) = false
contains_nothing(m::Op, d) = contains_nothing(m.l, d) || contains_nothing(m.r, d)
contains_nothing(m::String, d) = contains_nothing(d[m], d)

inverse(target, m::String, d::Dict) = inverse(target, d[m], d)
inverse(target, ::Nothing, ::Dict) = target

function inverse(target, m::Op, d::Dict)
    if contains_nothing(m.l, d)
        r = resolve(m.r, d)
        return inverse(linvops[m.op](target, r), m.l, d)
    elseif contains_nothing(m.r, d)
        l = resolve(m.l, d)
        return inverse(rinvops[m.op](l, target), m.r, d)
    else
        @error "uhhh, this shouldn't happen"
    end
end

function Base.:(==)(a::Op, b::Op)
    f = (:l, :r, :op)
    getfield.(Ref(a), f) == getfield.(Ref(b), f)
end

function part1(d)
    dict = Dict{String, Union{Op, Int}}(d)
    return resolve(dict["root"], dict)
end

function part2(d)
    dict = Dict{String, Union{Op, Int, Nothing}}(d)
    dict["humn"] = nothing

    root = dict["root"]
    if contains_nothing(root.l, dict)
        target = resolve(root.r, dict)
        return inverse(target, root.l, dict)
    else
        target = resolve(root.l, dict)
        return inverse(target, root.r, dict)
    end
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        numre = r"([a-z]{4}): ([0-9]+)"
        opre = r"([a-z]{4}): ([a-z]{4}) (.) ([a-z]{4})"
        if contains(l, numre)
            m = match(numre, l)
            return m[1] => parse(Int, m[2])
        else
            m = match(opre, l)
            return m[1] => Op(m[2], only(m[3]), m[4])
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    root: pppw + sjmn
    dbpl: 5
    cczh: sllz + lgvd
    zczc: 2
    ptdq: humn - dvpt
    dvpt: 3
    lfqf: 4
    humn: 5
    ljgn: 2
    sjmn: drzm * dbpl
    sllz: 4
    pppw: cczh / lfqf
    lgvd: ljgn * ptdq
    drzm: hmdt - zczc
    hmdt: 32
    """
const testarr = [
    "root" =>  Op("pppw", '+', "sjmn"),
    "dbpl" =>  5,
    "cczh" =>  Op("sllz", '+', "lgvd"),
    "zczc" =>  2,
    "ptdq" =>  Op("humn", '-', "dvpt"),
    "dvpt" =>  3,
    "lfqf" =>  4,
    "humn" =>  5,
    "ljgn" =>  2,
    "sjmn" =>  Op("drzm", '*', "dbpl"),
    "sllz" =>  4,
    "pppw" =>  Op("cczh", '/', "lfqf"),
    "lgvd" =>  Op("ljgn", '*', "ptdq"),
    "drzm" =>  Op("hmdt", '-', "zczc"),
    "hmdt" =>  32,
]

@testset "d21" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 152
    @test part2(testarr) == 301
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
