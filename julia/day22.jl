input = read("inputs/day22", String)
input = """
1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9
"""


lines = split(input, "\n") |> xs -> filter(x -> x != "", xs)

bricks = map(enumerate(lines)) do (i, line)
    line = split(line, "~")
    line = map(x -> split(x, ","), line)
    line = map(x -> map(y -> parse(Int, y), x), line)
    (
        index = i,
        x1 = line[1][1],
        y1 = line[1][2],
        z1 = line[1][3],
        x2 = line[2][1],
        y2 = line[2][2],
        z2 = line[2][3],
    )
end

sort!(bricks, by=x -> min(x.z1, x.z2))

begin
	highest_z = Dict()
	sits_on = Dict()
	children = Dict()
end

for brick in bricks
	max_z = 0
	for x in brick.x1:brick.x2
		for y in brick.y1:brick.y2
			xy = (x=x,y=y)
            max_z = max(max_z, get(highest_z, xy, (index=-1, z=0)).z)
		end
	end
	height = brick.z2 - brick.z1 + 1
	for x in brick.x1:brick.x2
		for y in brick.y1:brick.y2
			xy = (x=x,y=y)
            old = get(highest_z, xy, (index=-1, z=0))
            if old.z == max_z
                so = get(sits_on, brick.index, Set())
                push!(so, old.index)
                sits_on[brick.index] = so

                ibo = get(children, old.index, Set())
                push!(ibo, brick.index)
                children[old.index] = ibo
            end

            highest_z[xy] = (index=brick.index, z=max_z+height)
		end
	end
end

for c in children[-1]
    delete!(sits_on, c)
end

delete!(children, -1)

unsafe = Set()
for (k,v) in sits_on
    if length(v) == 1
        push!(unsafe, first(v))
    end
end

unsafe

println("Part 1: ", length(bricks) - length(unsafe))


# Part 2
function get_dependencies(children, brick)
    in_deg = Dict()

    for (parent, children) in children
        for child in children
            in_deg[child] = get(in_deg, child, 0) + 1
        end
    end

    dep = - 1
    Q = [brick]
    while length(Q) > 0
        b = popfirst!(Q)
        dep += 1
        for child in get(children, b, [])
            in_deg[child] -= 1
            if in_deg[child] == 0
                push!(Q, child)
            end
        end
    end

    return dep
end

begin
    p2 = 0

    for b in unsafe
        p2 += get_dependencies(children, b)
    end

    println("Part 2: ", p2)
end