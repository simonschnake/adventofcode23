using DataStructures

function to_field(input)
    input = split(input, "\n")
    input = filter(x -> x != "", input)
    input = collect.(input)
    input = hcat(input...)
    input = parse.(Int, input)
    return input
end

const DIR = (CartesianIndex(0, -1), CartesianIndex(0, 1), CartesianIndex(1, 0), CartesianIndex(-1, 0))
const UP = 1; const DOWN = 2; const RIGHT = 3; const LEFT = 4
const OPPOSITE = (DOWN, UP, LEFT, RIGHT)

function next(node, field)
    last_dir = node.last_dir
    possible_dirs = [UP, DOWN, RIGHT, LEFT]
    possible_dirs = filter(x -> checkbounds(Bool, field, node.pos + DIR[x]), possible_dirs) # remove out of bounds
    if last_dir != -1
        possible_dirs = filter(x -> x != OPPOSITE[last_dir], possible_dirs) # remove opposite direction
    end
    if node.same_dir_count == 3
        possible_dirs = filter(x -> x != last_dir, possible_dirs) # don't go more than 3 times in the same direction
    end

    return [
        (
            dist = node.dist + field[node.pos + DIR[dir]],
            pos = node.pos + DIR[dir],
            last_dir = dir,
            same_dir_count = last_dir == dir ? node.same_dir_count + 1 : 1
        )

        for dir in possible_dirs
    ]
end

"""
Algorithm: ShortestPath(G, v)  // a little miss leading since the output is only the distance

input: A simple undirected weighted graph G

with non negative edge weights and a start vertex, v.

output: D(u) the distance u is from v.

    Initialize D(v) = 0 and D(u) = inf for u != v
    Initialize priority queue Q of all vertices in G using D as the key.
    while Q is not empty do 

u = Q.removeMin()
for each vertex z adjacent to u and in Q do

if  D(u) + w((u, z)) < D(z) then

    D(z) = D(u) + w((u, z))

    update z in Q

return D
"""
function shortest_path(field)
    # Initialize distances

    distances = Dict()

    # Initialize priority queue
    queue = MutableBinaryMinHeap([ 
        (dist = 0, pos = CartesianIndex(1, 1), last_dir = -1, same_dir_count = 1)])

    while !isempty(queue)
        # Get next node
        node = pop!(queue)

        # Update distances
        if (node.pos, node.last_dir, node.same_dir_count) in keys(distances)
            continue
        end

        distances[(node.pos, node.last_dir, node.same_dir_count)] = node.dist

        # Get next nodes
        next_nodes = next(node, field)

        # Update queue
        for next_node in next_nodes
            push!(queue, next_node) 
        end 
    end

    return distances
end


input = read("inputs/day17", String)
input = """
2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533
"""
field = to_field(input)

distances = shortest_path(field)

ks = filter(x -> x[1] == CartesianIndex(size(field)), keys(distances))

minimum(distances[k] for k in ks)

# Part 2

function next(node, field)
    last_dir = node.last_dir
    possible_dirs = [UP, DOWN, RIGHT, LEFT]
    if last_dir != -1
        possible_dirs = filter(x -> x != OPPOSITE[last_dir], possible_dirs) # remove opposite direction

        if node.same_dir_count < 4
            possible_dirs = [last_dir]
        end
        if node.same_dir_count == 10
            possible_dirs = filter(x -> x != last_dir, possible_dirs) # don't go more than 3 times in the same direction
        end
    end
    possible_dirs = filter(x -> checkbounds(Bool, field, node.pos + DIR[x]), possible_dirs) # remove out of bounds

    return [
        (
            dist = node.dist + field[node.pos + DIR[dir]],
            pos = node.pos + DIR[dir],
            last_dir = dir,
            same_dir_count = last_dir == dir ? node.same_dir_count + 1 : 1
        )

        for dir in possible_dirs
    ]
end

distances = shortest_path(field)

ks = filter(x -> x[1] == CartesianIndex(size(field)), keys(distances))

minimum(distances[k] for k in ks)
