module d24

using Chain
using InlineTest
using DataStructures

abstract type AbstractBlizzard end

struct UBlizzard <: AbstractBlizzard
    c::NTuple{2,Int16}
end
struct DBlizzard <: AbstractBlizzard
    c::NTuple{2,Int16}
end
struct LBlizzard <: AbstractBlizzard
    c::NTuple{2,Int16}
end
struct RBlizzard <: AbstractBlizzard
    c::NTuple{2,Int16}
end

struct Map
    startc::NTuple{2,Int16}
    endc::NTuple{2,Int16}
    size::NTuple{2,Int16}
    bs::Vector{AbstractBlizzard}
end

Base.:(==)(a::Map, b::Map) = (a.startc, a.endc, a.size, Set(a.bs)) == (b.startc, b.endc, a.size, Set(b.bs))

move(b::UBlizzard, n) = UBlizzard(b.c .+ (-n, 0))
move(b::DBlizzard, n) = DBlizzard(b.c .+ (n, 0))
move(b::LBlizzard, n) = LBlizzard(b.c .+ (0, -n))
move(b::RBlizzard, n) = RBlizzard(b.c .+ (0, n))
move(b::AbstractBlizzard) = move(b, 1)

wrap(b::AbstractBlizzard, m::Map) = typeof(b)((mod(b.c[1], 1:m.size[1]), mod(b.c[2], 1:m.size[2])))

distance(c, m) = sum(abs.(c .- m.endc))

function blizzard_coords_at_time(t, m)
    return @chain begin
        m.bs
        map(_) do b
            @chain b move(_, t) wrap(_, m) _.c
        end
        Set
    end
end

function available_moves(c, bs, m)
    return @chain begin
        map(n -> c .+ n, NTuple{5,NTuple{2,Int16}}(((0, 0), (0, 1), (0, -1), (1, 0), (-1, 0))))
        Set
        setdiff(bs)
        filter(_) do n
            return ((n[1] >= 1 &&
                     n[1] <= m.size[1] &&
                     n[2] >= 1 &&
                     n[2] <= m.size[2]) ||
                    (n == m.startc) ||
                    (n == m.endc))
        end
    end
end

function sim(d; t0 = 0, reverse=false)
    queue = Set([reverse ? d.endc : d.startc])
    t = t0

    while true
        if (reverse ? d.startc : d.endc) ∈ queue
            return t
        end

        t += 1

        next = Set{NTuple{2,Int16}}()
        bs = blizzard_coords_at_time(t, d)

        for c in queue
            moves = available_moves(c, bs, d)
            next = union(next, moves)
        end

        queue = next
    end
end

function part1(d)
    sim(d)
end

function part2(d)
    t0 = sim(d)
    t1 = sim(d, t0=t0, reverse=true)
    return sim(d, t0=t1)
end

function parseinput(io)
    grid = mapreduce(vcat, eachline(io)) do l
        @chain l begin
            collect
            Vector{Char}(_)
            reshape(_, 1, :)
        end
    end
    s = findfirst(!=('#'), grid[1, :]) - 1
    e = findfirst(!=('#'), grid[end, :]) - 1
    gsize = size(grid) .- (2, 2)

    blocs = findall(in("<>v^"), grid)
    bs = map(blocs) do i
        c = grid[i]
        modc = Tuple(i) .- (1, 1)
        if c == '<'
            return LBlizzard(modc)
        elseif c == '>'
            return RBlizzard(modc)
        elseif c == '^'
            return UBlizzard(modc)
        elseif c == 'v'
            return DBlizzard(modc)
        end
    end

    return Map((0, s), (gsize[1] + 1, e), gsize, bs)
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    #.######
    #>>.<^<#
    #.<..<<#
    #>v.><>#
    #<^v^^>#
    ######.#
    """
const testarr = Map(
    (0, 1),
    (5, 6),
    (4, 6),
    [
        RBlizzard((1, 1)),
        RBlizzard((1, 2)),
        LBlizzard((1, 4)),
        UBlizzard((1, 5)),
        LBlizzard((1, 6)),
        LBlizzard((2, 2)),
        LBlizzard((2, 5)),
        LBlizzard((2, 6)),
        RBlizzard((3, 1)),
        DBlizzard((3, 2)),
        RBlizzard((3, 4)),
        LBlizzard((3, 5)),
        RBlizzard((3, 6)),
        LBlizzard((4, 1)),
        UBlizzard((4, 2)),
        DBlizzard((4, 3)),
        UBlizzard((4, 4)),
        UBlizzard((4, 5)),
        RBlizzard((4, 6)),
    ]
)

const testarr_t1 = [
    (1, 2),  # RBlizzard((1, 1)),
    (1, 3),  # RBlizzard((1, 2)),
    (1, 3),  # LBlizzard((1, 4)),
    (4, 5),  # UBlizzard((1, 5)),
    (1, 5),  # LBlizzard((1, 6)),
    (2, 1),  # LBlizzard((2, 2)),
    (2, 4),  # LBlizzard((2, 5)),
    (2, 5),  # LBlizzard((2, 6)),
    (3, 2),  # RBlizzard((3, 1)),
    (4, 2),  # DBlizzard((3, 2)),
    (3, 5),  # RBlizzard((3, 4)),
    (3, 4),  # LBlizzard((3, 5)),
    (3, 1),  # RBlizzard((3, 6)),
    (4, 6),  # LBlizzard((4, 1)),
    (3, 2),  # UBlizzard((4, 2)),
    (1, 3),  # DBlizzard((4, 3)),
    (3, 4),  # UBlizzard((4, 4)),
    (3, 5),  # UBlizzard((4, 5)),
    (4, 1),  # RBlizzard((4, 6)),
]

@testset "d24" begin
    @test parseinput(IOBuffer(teststr)) == testarr #
    @test part1(testarr) == 18
    @test blizzard_coords_at_time(1, testarr) == Set(testarr_t1)
    @test part2(testarr) == 54
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
