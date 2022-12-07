module d07

using Chain
using InlineTest
using AbstractTrees

mutable struct Node
    size::Int
    children::Vector{Node}
    parent::Union{Node,Nothing}
end

AbstractTrees.parent(x::Node) = x.parent
AbstractTrees.children(x::Node) = x.children
AbstractTrees.nodevalue(x::Node) = x.size

function parsedirs(d)
    root = Node(0, [], nothing)
    current = root
    cs = strip.(split(d, '$'))
    for c in cs[2:end]
        if startswith(c, "ls")
            result = split(c, '\n')[2:end]
            files = filter(c -> startswith(c, r"[0-9]"), result)
            sizes = map(files) do f
                m = match(r"([0-9]+) (.*)", f)
                return m[1]
            end
            current.size = sum(parse.(Int, sizes))
        elseif startswith(c, "cd")
            if startswith(c, "cd ..")
                current = current.parent
            else
                dname = match(r"^cd (.*)$", c)[1]
                new = Node(0, [], current)
                push!(current.children, new)
                current = new
            end
        end
    end
    return root
end

function part1(d)
    @chain d begin
        parsedirs
        map(PreOrderDFS(_)) do d
            sum(d -> d.size, PreOrderDFS(d))
        end
        filter(<=(100000), _)
        sum
    end
end

function part2(d)
    dirs = parsedirs(d)
    used = sum(d -> d.size, PreOrderDFS(dirs))
    total = 70000000
    free = total - used
    needed = 30000000 - free

    @chain dirs begin
        map(PreOrderDFS(_)) do d
            sum(d -> d.size, PreOrderDFS(d))
        end
        filter(>=(needed), _)
        minimum
    end
end

function parseinput(io)
    strip(read(io, String))
end

solve(v) = (part1(v), part2(v))
solve(io::IO) = solve(parseinput(io))

const teststr = raw"""
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """
const testarr = teststr

@testset "d07" begin
    @test parseinput(IOBuffer(teststr)) == strip(testarr)
    @test part1(testarr) == 95437
    @test part2(testarr) == 24933642
    # @test solve(IOBuffer(teststr)) == (nothing, nothing)
end

end
