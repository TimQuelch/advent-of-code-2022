module d15

using Chain
using InlineTest

dist(a, b) = sum(abs.(a .- b))

function sensor_radii(d)
    return map(d) do s
        return (s = s.sensor, r = dist(s.sensor, s.beacon))
    end
end

function part1(d, y=2000000)
    radii = sensor_radii(d)

    relevant = filter(radii) do s
        abs(s.s[2] - y) <= s.r
    end

    ranges = map(relevant) do s
        vdist = abs(s.s[2] - y)
        spread = (s.r - vdist)
        s.s[1] - spread : s.s[1] + spread
    end

    inrow = @chain d begin
        map(s -> s.beacon, _)
        filter(b -> b[2] == y, _)
        unique
        length
    end

    return length(unique(reduce(vcat, ranges))) - inrow
end

function check_point_single(sensor, radius, p)
    return dist(sensor, p) <= radius
end

function within_any_radius(radii, p)
    return any(sr -> check_point_single(sr.s, sr.r, p), radii)
end

function in_bounds(p, max)
    return p[1] >= 0 && p[1] <= max && p[2] >= 0 && p[2] <= max
end

function check_ring(s, r, max, radii)
    for xd in -r-1:r+1
        x = s[1] + xd
        yd = (r + 1) - xd
        y1 = s[2] + yd
        y2 = s[2] - yd
        if in_bounds((x, y1), max) && !within_any_radius(radii, (x, y1))
            return (x, y1)
        end
        if in_bounds((x, y2), max) && !within_any_radius(radii, (x, y2))
            return (x, y2)
        end
    end
    return nothing
end

function part2(d, max=4000000)
    radii = sensor_radii(d)
    for s in radii
        result = check_ring(s.s, s.r, max, radii)
        if !isnothing(result)
            return result[1] * 4000000 + result[2]
        end
    end
end

function parseinput(io)
    mapreduce(vcat, eachline(io)) do l
        m = match(r"Sensor at x=([-0-9]+), y=([-0-9]+): closest beacon is at x=([-0-9]+), y=([-0-9]+)", l)
        i = parse.(Int, m)
        return (sensor=(i[1], i[2]), beacon=(i[3], i[4]))
    end
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = """
    Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    Sensor at x=9, y=16: closest beacon is at x=10, y=16
    Sensor at x=13, y=2: closest beacon is at x=15, y=3
    Sensor at x=12, y=14: closest beacon is at x=10, y=16
    Sensor at x=10, y=20: closest beacon is at x=10, y=16
    Sensor at x=14, y=17: closest beacon is at x=10, y=16
    Sensor at x=8, y=7: closest beacon is at x=2, y=10
    Sensor at x=2, y=0: closest beacon is at x=2, y=10
    Sensor at x=0, y=11: closest beacon is at x=2, y=10
    Sensor at x=20, y=14: closest beacon is at x=25, y=17
    Sensor at x=17, y=20: closest beacon is at x=21, y=22
    Sensor at x=16, y=7: closest beacon is at x=15, y=3
    Sensor at x=14, y=3: closest beacon is at x=15, y=3
    Sensor at x=20, y=1: closest beacon is at x=15, y=3
    """
const testarr = [
    (sensor=(2, 18), beacon=(-2, 15)),
    (sensor=(9, 16), beacon=(10, 16)),
    (sensor=(13, 2), beacon=(15, 3)),
    (sensor=(12, 14), beacon=(10, 16)),
    (sensor=(10, 20), beacon=(10, 16)),
    (sensor=(14, 17), beacon=(10, 16)),
    (sensor=(8, 7), beacon=(2, 10)),
    (sensor=(2, 0), beacon=(2, 10)),
    (sensor=(0, 11), beacon=(2, 10)),
    (sensor=(20, 14), beacon=(25, 17)),
    (sensor=(17, 20), beacon=(21, 22)),
    (sensor=(16, 7), beacon=(15, 3)),
    (sensor=(14, 3), beacon=(15, 3)),
    (sensor=(20, 1), beacon=(15, 3)),
]

@testset "d15" begin
    @test parseinput(IOBuffer(teststr)) == testarr
    @test part1(testarr, 10) == 26
    @test part2(testarr, 20) == 56000011
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
