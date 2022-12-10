module d10

using Chain
using InlineTest

# This isn't super efficient, but as of part 1 it isn't known
# that the output is a fixed length of 240
function genx(d)
    # use foldl instead of reduce to guarantee init value is used correctly
    vals = foldl(d; init=[1]) do v, i
        if i[1] == "noop"
            return push!(v, 0)
        else
            return append!(v, [0, i[2]])
        end
    end
    return cumsum(vals)
end

function part1(d)
    accum = genx(d)
    return map(i -> i * accum[i], 20:40:220) |> sum
end

function part2(d)
    # Generate binary array of result
    result = @chain d begin
        genx(_)[1:240]
        _ .- repeat(0:39, outer=6)
        abs.(_) .<= 1
        reshape(_, (40, 6))
        transpose
    end

    # Generate string representation
    screen = fill('.', (6, 40))
    screen[result] .= '#'
    return @chain screen begin
	    map(String, eachrow(_))
        join(_, '\n')
    end
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        if contains(l, "noop")
            return ("noop",)
        else
            s = split(l, " ")
            return ("addx", parse(Int, s[2]))
        end
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    noop
    addx 3
    addx -5
    """
const testarr = [
    ("noop",),
    ("addx", 3),
    ("addx", -5),
]

const teststr2 = """
    addx 15
    addx -11
    addx 6
    addx -3
    addx 5
    addx -1
    addx -8
    addx 13
    addx 4
    noop
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx -35
    addx 1
    addx 24
    addx -19
    addx 1
    addx 16
    addx -11
    noop
    noop
    addx 21
    addx -15
    noop
    noop
    addx -3
    addx 9
    addx 1
    addx -3
    addx 8
    addx 1
    addx 5
    noop
    noop
    noop
    noop
    noop
    addx -36
    noop
    addx 1
    addx 7
    noop
    noop
    noop
    addx 2
    addx 6
    noop
    noop
    noop
    noop
    noop
    addx 1
    noop
    noop
    addx 7
    addx 1
    noop
    addx -13
    addx 13
    addx 7
    noop
    addx 1
    addx -33
    noop
    noop
    noop
    addx 2
    noop
    noop
    noop
    addx 8
    noop
    addx -1
    addx 2
    addx 1
    noop
    addx 17
    addx -9
    addx 1
    addx 1
    addx -3
    addx 11
    noop
    noop
    addx 1
    noop
    addx 1
    noop
    noop
    addx -13
    addx -19
    addx 1
    addx 3
    addx 26
    addx -30
    addx 12
    addx -1
    addx 3
    addx 1
    noop
    noop
    noop
    addx -9
    addx 18
    addx 1
    addx 2
    noop
    noop
    addx 9
    noop
    noop
    noop
    addx -1
    addx 2
    addx -37
    addx 1
    addx 3
    noop
    addx 15
    addx -21
    addx 22
    addx -6
    addx 1
    noop
    addx 2
    addx 1
    noop
    addx -10
    noop
    noop
    addx 20
    addx 1
    addx 2
    addx 2
    addx -6
    addx -11
    noop
    noop
    noop
    """

const resultstr = """
    ##..##..##..##..##..##..##..##..##..##..
    ###...###...###...###...###...###...###.
    ####....####....####....####....####....
    #####.....#####.....#####.....#####.....
    ######......######......######......####
    #######.......#######.......#######.....
    """

@testset "d10" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    # @test part1(testarr) == nothing
    @test part1(parseinput(IOBuffer(teststr2))) == 13140
    @test part2(parseinput(IOBuffer(teststr2))) == strip(resultstr)
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
