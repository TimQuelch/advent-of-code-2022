module d14

using Chain
using InlineTest
using OffsetArrays

function minmaxes(d)
    minx, maxx = @chain d begin
        map(_) do p
            map(c -> c[1], p)
        end
        Iterators.flatten
        extrema
    end
    miny, maxy = @chain d begin
        map(_) do p
            map(c -> c[2], p)
        end
        Iterators.flatten
        extrema
    end
    @assert minx <= 500 <= maxx
    return ((minx, maxx), (0, maxy))
end

function build_initial_grid(d)
    limits = minmaxes(d)
    xindices = limits[1][1]:limits[1][2]
    yindices = limits[2][1]:limits[2][2]
    g = OffsetArray(falses(length(xindices), length(yindices)), xindices, yindices)
    for p in d
        for i in eachindex(p)[2:end]
            xs, ys = p[i-1]
            xe, ye = p[i]
            xs, xe = minmax(xs, xe)
            ys, ye = minmax(ys, ye)
            g[xs:xe, ys:ye] .= true
        end
    end
    return g, count(g)
end

function build_initial_grid_p2(d)
    limits = minmaxes(d)
    xindices = (500-limits[2][2]-2):(500+limits[2][2]+2)
    yindices = limits[2][1]:limits[2][2]+2
    g = OffsetArray(falses(length(xindices), length(yindices)), xindices, yindices)
    for p in d
        for i in eachindex(p)[2:end]
            xs, ys = p[i-1]
            xe, ye = p[i]
            xs, xe = minmax(xs, xe)
            ys, ye = minmax(ys, ye)
            g[xs:xe, ys:ye] .= true
        end
    end
    g[:, end] .= true
    return g, count(g)
end

function isblocked(g, c)
    return all(g[c[1]-1:c[1]+1, c[2]+1])
end

function willescape(g, c)
    return !checkbounds(Bool, g, c[1]-1:c[1]+1, c[2]+1)
end

function move(g, c)
    if !g[c[1], c[2]+1]
        return (c[1], c[2]+1)
    elseif !g[c[1]-1, c[2]+1]
        return (c[1]-1, c[2]+1)
    elseif !g[c[1]+1, c[2]+1]
        return (c[1]+1, c[2]+1)
    else
        @error "This shouldn't happen"
    end
end

function simonce(g)
    c = (500, 0)
    while !willescape(g, c) && !isblocked(g, c)
        c = move(g, c)
    end
    if willescape(g, c)
        return true
    end
    g[c[1], c[2]] = true
    return false
end

function simonce_p2(g)
    c = (500, 0)
    while !isblocked(g, c)
        c = move(g, c)
    end
    g[c[1], c[2]] = true

    return c == (500, 0)
end

function part1(d)
    g, initial_count = build_initial_grid(d)
    ended = false
    while !ended
        ended = simonce(g)
    end
    return count(g) - initial_count
end

function part2(d)
    g, initial_count = build_initial_grid_p2(d)
    ended = false
    while !ended
        ended = simonce_p2(g)
    end
    return count(g) - initial_count
end

function parseinput(io)
    map(eachline(io)) do l
        @chain l begin
            split(_, " -> ")
            map(_) do coord
                @chain coord begin
                    split.(_, ',')
                    parse.(Int, _)
                    tuple(_...)
                end
            end
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    498,4 -> 498,6 -> 496,6
    503,4 -> 502,4 -> 502,9 -> 494,9
    """
const testarr = [
    [(498,4), (498,6), (496,6)],
    [(503,4), (502,4), (502,9), (494,9)]
]

@testset "d14" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 24
    @test minmaxes(testarr) == ((494, 503), (0, 9))
    @test part2(testarr) == 93
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
