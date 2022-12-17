module d17

using Chain
using InlineTest

const shapes = [
    Bool[1 1 1 1],
    Bool[0 1 0; 1 1 1; 0 1 0],
    Bool[0 0 1; 0 0 1; 1 1 1],
    Bool[1; 1; 1; 1],
    Bool[1 1; 1 1]
]

function aindices(a, r, c)
    x, y = c
    return x:x+size(r, 1)-1, y:y+size(r, 2)-1
end

function check_collision(a, r, c)
    xi, yi = aindices(a, r, c)
    if !checkbounds(Bool, a, xi, yi)
        return true
    end
    aview = view(a, xi, yi)
    return any(aview .& r)
end

function sim(d, nrocks)
    height = 5000               # hopefully this is big enough
    a = falses(7, height)
    # @info jet
    jet = Iterators.Stateful(Iterators.cycle(d))
    for originalr in Iterators.take(Iterators.cycle(shapes), 2022)
        r = transpose(originalr)[:, end:-1:1]
        startheight = findlast(any, eachcol(a))
        if isnothing(startheight)
            startheight = 0
        end
        c = (3, startheight + 4)

        # @info "start pos" c

        for j in jet
            # Move laterally
            newc = c
            # @info j
            if j == '<'
                newc = (newc[1] - 1, newc[2])
            elseif j == '>'
                newc = (newc[1] + 1, newc[2])
            else
                @error "This shouldn't happen" j
            end
            if !check_collision(a, r, newc)
                c = newc
            end

            # Move down
            newc = (c[1], c[2] - 1)

            if check_collision(a, r, newc)
                xi, yi = aindices(a, r, c)
                aview = view(a, xi, yi)
                aview .= r .| aview
                break
            end

            c = newc
        end
        # @info "array" a[:, 1:c[2]+5]
    end
    return findlast(any, eachcol(a))
end

function part1(d)
    sim(d, 2022)
end

function part2(d)
    sim(d, 1000000000000)
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
