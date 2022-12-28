module d22

using Chain
using InlineTest
using StaticArrays

const Vec = SVector{2, Int16}

turn_r(c) = [0 1; -1 0] * c
turn_l(c) = [0 -1; 1 0] * c

const test_edge_lookup = [
    (5, false, [1, 0]),
    (14, true, [-1, 0]),
    (12, true, [-1, 0]),

    (6, true, [1, 0]),
    (1, false, [0, 1]),
    (4, true, [1, 0]),
    (9, true, [0, -1]),

    (10, true, [0, -1]),
    (7, true, [1, 0]),
    (8, true, [0, -1]),

    (13, true, [-1, 0]),
    (3, true, [0, 1]),
    (11, true, [-1, 0]),
    (2, true, [0, 1]),
]
const real_edge_lookup = [
    (3, true, [0, 1]),          #1 left
    (5, false, [1, 0]),         #2
    (1, true, [0, 1]),          #3
    (6, false, [1, 0]),         #4

    (2, false, [0, 1]),         #5 top
    (4, false, [0, 1]),         #6
    (12, false, [-1, 0]),       #7

    (10, true, [0, -1]),        #8 right
    (14, false, [-1, 0]),       #9
    (8, true, [0, -1]),         #10
    (13, false, [-1, 0]),       #11

    (7, false, [1, 0]),         #12 bottom
    (11, false, [0, -1]),       #13
    (9, false, [0, -1]),        #14
]

function edge_mapping(g)
    edge_size = @chain begin
        (g[begin, :], g[end, :], g[:, begin], g[:, end])
        map(e -> count(!isnothing, e), _)
        minimum
    end

    @assert size(g, 1) % edge_size == 0
    @assert size(g, 2) % edge_size == 0

    left_es = @chain begin
        1:edge_size:size(g, 1)
        map(r -> (r:r+edge_size-1, findfirst(!isnothing, g[r, :])), _)
    end
    right_es = @chain begin
        1:edge_size:size(g, 1)
        map(r -> (r:r+edge_size-1, findlast(!isnothing, g[r, :])), _)
    end
    top_es = @chain begin
        1:edge_size:size(g, 2)
        map(c -> (findfirst(!isnothing, g[:, c]), c:c+edge_size-1), _)
    end
    bottom_es = @chain begin
        1:edge_size:size(g, 2)
        map(c -> (findlast(!isnothing, g[:, c]), c:c+edge_size-1), _)
    end
    edges = reduce(vcat, (left_es, top_es, right_es, bottom_es))
    @info "left edges" left_es
    @info "top edges" top_es
    @info "right edges" right_es
    @info "bottom edges" bottom_es

    @info "edges" edges

    # @show findfirst(<(0), diff(getindex.(left_es, 2)))
    # @show findfirst(<(0), diff(getindex.(top_es, 1)))


    return map(e -> Vec.(e...), edges)
end

function wrap1(g, c, d, _)
    prev = c .- d
    while checkbounds(Bool, g, prev...) && !isnothing(g[prev...])
        c = prev
        prev = c .- d
    end
    return c, d
end

make_wrap_2(lookup) = (args...) -> wrap2(args..., lookup)

function wrap2(g, c, d, em, lookup)
    current_edge = findfirst(e -> c ∈ e, em)
    next_edge, rev, nextdir = lookup[current_edge]
    current_edge_i = findfirst(==(c), em[current_edge])
    # @info "index in current edge" current_edge_i
    mapping = rev ? reverse(em[next_edge]) : em[next_edge]
    nextc = mapping[current_edge_i]
    # @info "next coord" nextc

    return nextc, nextdir
end

function sim(in, wrapfn)
    g, is = deepcopy(in)
    c = Vec(1, findfirst(p -> !isnothing(p) && p, g[1, :]))
    d = Vec(0, 1)

    points = [c]

    em = edge_mapping(g)
    @info "edges expanded" em

    for i in is
        if typeof(i) == Char
            if i == 'R'
                d = turn_r(d)
            elseif i == 'L'
                d = turn_l(d)
            end
        else
            for _ in 1:i
                next = c .+ d
                dirnext = d
                if !checkbounds(Bool, g, next...) || isnothing(g[next...])
                    next, dirnext = wrapfn(g, c, d, em)
                end

                if g[next...]
                    c = next
                    push!(points, c)
                    d = dirnext
                end
            end
        end
    end

    facinglookup = Dict(
        [0, 1] => 0,
        [1, 0] => 1,
        [0, -1] => 2,
        [-1, 0] => 3
    )

    @show c, d
    return 1000 * c[1] + 4 * c[2] + facinglookup[d], points
end

function display(g, points)
    screen = fill(' ', size(g))
    screen[(!).(isnothing.(g)) .&& g .== true] .= '.'
    screen[(!).(isnothing.(g)) .&& g .== false] .= '#'
    screen[map(i -> CartesianIndex(i...), points)] .= 'o'
    return @chain screen begin
	    map(String, eachrow(_))
        join(_, '\n')
    end
end

function part1(d)
    score, points = sim(d, wrap1)
    # println(display(d[1], points))
    return score
end
function part2(d, lookup=real_edge_lookup)
    score, points = sim(d, make_wrap_2(lookup))
    println(display(d[1], points))
    return score
end
function parseinput(io)
    s = collect(eachline(io))
    istr = s[end]
    gridlines = s[1:end-2]
    maxw = map(length, gridlines) |> maximum

    grid = mapreduce(vcat, gridlines) do l
        @chain begin
            rpad(l, maxw, ' ')
            map(collect(_)) do c
                if c == '#'
                    return false
                elseif c == '.'
                    return true
                else
                    return nothing
                end
            end
            Vector{Union{Bool,Nothing}}(_)
            reshape(_, 1, :)
        end
    end

    instructions = Union{Int,Char}[]
    while !isempty(istr)
        if startswith(istr, r"[0-9]")
            m = match(r"^([0-9]+)", istr)
            push!(instructions, parse(Int, m[1]))
            istr = istr[length(m[1])+1:end]
        else
            push!(instructions, istr[1])
            istr = istr[2:end]
        end
    end

    return grid, instructions
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
            ...#
            .#..
            #...
            ....
    ...#.......#
    ........#...
    ..#....#....
    ..........#.
            ...#....
            .....#..
            .#......
            ......#.

    10R5L5R10L4R5L5
    """
# I can't be bothered testing the map...
const testarr = [10, 'R', 5, 'L', 5, 'R', 10, 'L', 4, 'R', 5, 'L', 5]

@testset "d22" begin
    @test parseinput(IOBuffer(teststr))[2] == testarr
    @test part1(parseinput(IOBuffer(teststr))) == 6032
    @test part2(parseinput(IOBuffer(teststr)), test_edge_lookup) == 5031
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
