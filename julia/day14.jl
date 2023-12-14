input = read("inputs/day14", String)

function to_field(s)
    s = split(s, "\n")
    s = filter(x -> x != "", s)
    s = collect.(s)
    s = hcat(s...)
    return s
end

test_input = """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
"""

all_rocks(field) = findall(x -> x == 'O', field)

#  ----> y
# |
# |
# v
# x    
# field[y, x]

direction = Dict(
    :north => CartesianIndex(0, -1),
    :south => CartesianIndex(0, 1),
    :east => CartesianIndex(1, 0),
    :west => CartesianIndex(-1, 0),
)

function rock_can_move(field, rock, dir)
    Δpos = direction[dir]

    pos = rock + Δpos

    # Check if we are still on the field
    !checkbounds(Bool, field, pos) && return false

    field[pos] == '.' && return true

    return false
end

function move_rock!(field, rock, dir)
    Δpos = direction[dir]
    pos = rock + Δpos
    field[rock] = '.'
    field[pos] = 'O'
    return pos
end


function move_all_rocks!(field, dir)
    rocks = all_rocks(field)
    if dir == :south || dir == :east
        rocks = reverse(rocks)
    end

    for rock in rocks
        while rock_can_move(field, rock, dir)
            rock = move_rock!(field, rock, dir)
        end
    end
    return field
end

function total_load(field)
    map(enumerate(eachcol(field))) do (i, row)
        sum(row .== 'O') * (size(field, 1) + 1 - i)
    end |> sum
end

field = to_field(input)
field = move_all_rocks!(field, :north)
total_load(field)

# second part

# the field is the state
# we use the floyd 

function next(field)
    field = copy(field)
    field = move_all_rocks!(field, :north)
    field = move_all_rocks!(field, :west)
    field = move_all_rocks!(field, :south)
    field = move_all_rocks!(field, :east)
    return field
end

function floyd(x0)
    tortoise = next(x0)
    hare = next(next(x0))

    while tortoise != hare
        tortoise = next(tortoise)
        hare = next(next(hare))
    end

    start_of_cycle = 0
    tortoise = x0
    while tortoise != hare
        tortoise = next(tortoise)
        hare = next(hare)
        start_of_cycle += 1
    end
    
    cycle_length = 1

    hare = next(tortoise)
    while tortoise != hare
        hare = next(hare)
        cycle_length += 1
    end

    return start_of_cycle, cycle_length
end

# go to start of cycle

const cycles = 1_000_000_000

field_s = next(next(field))

next(field_s) .== field_s

move_all_rocks!(field_s, :north)
total_load(field_s)


field = to_field(test_input)

field_s = to_field("""
.....#....
....#...O#
...OO##...
.OO#......
.....OOO#.
.O#...O#.#
....O#....
......OOOO
#...O###..
#..OO#....
"""
)

field = to_field(test_input)

field_s == next(field)

field_s2 = to_field("""
.....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#..OO###..
#.OOO#...O
"""
)  

field_s2 == next(next(field))

field_s3 = to_field("""
.....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#...O###.O
#.OOO#...O
"""
)

field_s3 == next(next(next(field)))

field = to_field(input)

start_of_cycle, cycle_length = floyd(field)

(cycles - start_of_cycle) % cycle_length

for _ in 1:start_of_cycle
    field = next(field)
end

for _ in 1:((cycles - start_of_cycle) % cycle_length)
    field = next(field)
end

total_load(field)