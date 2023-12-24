input = read("inputs/day23", String)

test_input = """
#.#####################
#.......#########...###
#######.#########.#.###
###.....#.>.>.###.#.###
###v#####.#v#.###.#.###
###.>...#.#.#.....#...#
###v###.#.#.#########.#
###...#.#.#.......#...#
#####.#.#.#######.#.###
#.....#.#.#.......#...#
#.#####.#.#.#########v#
#.#...#...#...###...>.#
#.#.#v#######v###.###v#
#...#.>.#...>.>.#.###.#
#####v#.#.###v#.#.###.#
#.....#...#...#.#.#...#
#.#########.###.#.#.###
#...###...#...#...#.###
###.###.#.###v#####v###
#...#...#.#.>.>.#.>.###
#.###.###.#.###.#.#v###
#.....###...###...#...#
#####################.#
"""

lines = split(input, "\n") |> xs -> filter(x -> x != "", xs)

field = hcat(collect.(lines)...)

const GOAL_Y = collect(1:size(field, 1))[field[:, end] .== '.'] |> first
const GOAL_X = size(field, 2)

const START_Y = collect(1:size(field, 1))[field[:, 1] .== '.'] |> first
const START_X = 1

start_pos = (START_X, START_Y)

function calc_max_steps()
q = [(start_pos..., Set([start_pos]))]

#pf = copy(field)

SEEN = Dict()

max_steps = 0

while !isempty(q)
    x, y, steps = popfirst!(q)

    SEEN[(x, y)] = length(steps)

    #pf[y, x] = 'O'
    #print_field(pf)

    possible = []

    if field[y, x] == 'v'
        possible = [(x+1, y),]
    elseif field[y, x] == '^'
        possible = [(x-1, y),]
    elseif field[y, x] == '>'
        possible = [(x, y+1),]
    elseif field[y, x] == '<'
        possible = [(x, y-1),]
    elseif field[y, x] == '.'
        possible = [(x+1, y), (x-1, y), (x, y+1), (x, y-1)]
    end

    for (x, y) in possible
        if !checkbounds(Bool, field, CartesianIndex(y, x)) || field[y, x] == '#'
            continue
        end
        if (x, y) in steps
            continue
        end
        if haskey(SEEN, (x, y)) && length(SEEN[(x, y)]) >= length(steps) + 1
            continue
        end

        push!(q, (x, y, union(steps, [(x, y)])))
    end
end
return SEEN
end

seen = calc_max_steps()

seen[(GOAL_X, GOAL_Y)] - 1

function print_field(field, y, x)
    f = copy(field)
    f[y, x] = 'O'
for col in eachcol(f)
    println(join(col))
end
end


# Part 2



function build_graph()
    q = [(START_Y, START_X, START_Y, START_X)]

    graph = Dict()
    seen = Set()

    while !isempty(q)
        y, x, y_start, x_start =  popfirst!(q)

        if (y, x, y_start, x_start) in seen
            continue
        end

        push!(seen, (y, x, y_start, x_start))

        y_last, x_last = y_start, x_start
        steps = 0
        next = []
        while true
            next = [(y, x+1), (y, x-1), (y+1, x), (y-1, x)]
            steps += 1
            next = filter(p -> checkbounds(Bool, field, CartesianIndex(p...)) && field[p...] != '#', next)
            next = filter(p -> p != (y_last, x_last), next)
            if length(next) != 1
                break
            end
            y_last, x_last = y, x
            y, x = first(next)
            #print_field(field, y, x)
        end


        if (y, x) == (GOAL_Y, GOAL_X)
            graph[(y_start, x_start)] = [(GOAL_Y, GOAL_X, steps)] # reach the goal
        end

        if length(next) > 0 # at there is not a dead end
            if haskey(graph, (y_start, x_start))
                push!(graph[(y_start, x_start)], (y, x, steps))
            else
                graph[(y_start, x_start)] = [(y, x, steps)]
            end

            if haskey(graph, (y, x))
                push!(graph[(y, x)], (y_start, x_start, steps))
            else
                graph[(y, x)] = [(y_start, x_start, steps)]
            end

            push!(seen, (y_last, x_last, y, x)) # prevent to go back
        end

        for (y_next, x_next) in next
            push!(q, (y_next, x_next, y, x))
        end
    end

    return graph
end

graph = build_graph()

function walk_graph()

max_steps = 0

q = [(START_Y, START_X, 0, Set([(START_Y, START_X)]))]

while !isempty(q)
    y, x, sp, steps = popfirst!(q)

    next = graph[(y, x)]

    next = filter(p -> !((p[1], p[2]) in steps), next)

    for n in next
        y, x, s = n
        if (y, x) == (GOAL_Y, GOAL_X)
            # println(sp + s)
            max_steps = max(max_steps, sp+s)
            continue
        end
        push!(q, (y, x, sp + s, union(steps, [(y, x)])))
    end
end 
    return max_steps
end

walk_graph() - 1

