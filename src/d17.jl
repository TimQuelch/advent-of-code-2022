module d17

using Chain
using InlineTest
using StaticArrays

struct State
    ri::Int
    ji::Int
    top::SArray{Tuple{7, 8}, Bool}
end

const shapes = [
    Bool[1 1 1 1],
    Bool[0 1 0; 1 1 1; 0 1 0],
    Bool[0 0 1; 0 0 1; 1 1 1],
    Bool[1; 1; 1; 1],
    Bool[1 1; 1 1]
]

function aindices(r, c)
    x, y = c
    return x:x+size(r, 1)-1, y:y+size(r, 2)-1
end

function check_collision(a, r, c)
    xi, yi = aindices(r, c)
    if !checkbounds(Bool, a, xi, yi)
        return true
    end
    aview = view(a, xi, yi)
    return any(aview .& r)
end

function sim(d, nrocks)
    height = 6000               # This should be big enough...
    a = falses(7, height)
    # @info jet

    history = Dict{State, Tuple{Int, Int}}()

    t = 0                       # number of rocks dropped
    ri = 0                      # current index of rock
    ji = 0                      # current index of jet direction
    maxy = 0                    # height of the tower
    maxyi = 0                   # index of top of the tower. Different to height once cycles are added
    offset_accum = 0            # accumulated offset of index to height
    while t < nrocks
        # Increment rock counters
        t = t + 1
        ri = mod(ri + 1, 1:length(shapes))

        # Get rock and starting position
        r = transpose(shapes[ri])[:, end:-1:1]
        c = (3, maxyi + 4)

        while true
            # Move laterally
            newc = c
            ji = mod(ji + 1, 1:length(d)) # Increment jet counter
            if d[ji] == '<'
                newc = (newc[1] - 1, newc[2])
            elseif d[ji] == '>'
                newc = (newc[1] + 1, newc[2])
            else
                @error "This shouldn't happen" d[ji]
            end
            if !check_collision(a, r, newc)
                c = newc
            end

            # Move down
            newc = (c[1], c[2] - 1)

            if check_collision(a, r, newc)
                xi, yi = aindices(r, c)
                aview = view(a, xi, yi)
                aview .= r .| aview

                # Need to do the extra max here to ensure that if rock falls into a hole the current
                # highest point is still saved
                maxyi = max(maximum(yi), maxyi)
                maxy = maxyi + offset_accum

                # Only start cycle detection after pattern has settled
                if t > 250
                    # Store the current state. Indices and top 8 rows
                    state = State(ri, ji, SArray{Tuple{7, 8}, Bool}(a[:, maxyi-7:maxyi]))

                    if haskey(history, state)
                        # If we have seen the state before, we "repeat" that cycle until just before the end
                        ot, oh = history[state]
                        hdiff = maxy - oh
                        tdiff = t - ot
                        if tdiff < nrocks - t
                            ncycles = div(nrocks - t, tdiff)
                            t = t + ncycles * tdiff
                            offset = ncycles * hdiff
                            maxy += offset
                            offset_accum += offset
                            history[state] = (t, maxy)
                        end
                    else
                        # Else we store the state and the current height
                        history[state] = (t, maxy)
                    end
                end

                break
            end

            # Update the array
            c = newc
        end
    end
    # history is not actually needed to be returned, but was useful for debugging
    return maxy, history
end

function part1(d)
    sim(d, 2022)[1]
end

function part2(d)
    sim(d, 1000000000000)[1]
end

function parseinput(io)
    strip(read(io, String))
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """>>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"""
const testarr = teststr

@testset "d17" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr) == 3068
    @test part2(testarr) == 1514285714288
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
