field = hcat(collect.(readlines("inputs/day10"))...)
field = permutedims(field, [2, 1])

pipes = Dict(
    '|' => Dict("N" => "S", "S" => "N"),
    '-' => Dict("E" => "W", "W" => "E"),
    'L' => Dict("N" => "E", "E" => "N"),
    'J' => Dict("N" => "W", "W" => "N"),
    '7' => Dict("S" => "W", "W" => "S"),
    'F' => Dict("S" => "E", "E" => "S"),
    '.' => Dict(),
)


function get_start_pos(field)
    for y in 1:size(field, 1)
        for x in 1:size(field, 2)
            if field[y, x] == 'S'
                return (x, y)
            end
        end
    end
end


coming_from = Dict(
    "N" => "S",
    "S" => "N",
    "E" => "W",
    "W" => "E",
)

pos_change = Dict(
    "N" => (0, -1),
    "S" => (0, 1),
    "E" => (1, 0),
    "W" => (-1, 0),
)

function get_next_pos(field, pos, direction)
    pipe = field[pos[2], pos[1]]
    next_direction = pipes[pipe][coming_from[direction]]
    pc = pos_change[next_direction]
    return (pos[1] + pc[1], pos[2] + pc[2]), next_direction
end

pos = get_start_pos(field)
pos, dir  = (pos[1], pos[2]+1), "S"

function game(field, pos, dir)
    i = 1
    while field[pos[2], pos[1]] != 'S'
        pos, dir = get_next_pos(field, pos, dir)
        i += 1
    end
    return i
end

game(field, pos, dir) ÷ 2

# Part 2

function create_loop(field, start_pos) 
    loop = zeros(Bool, size(field))
    loop[start_pos[2], start_pos[1]] = true
    pos = (start_pos[1], start_pos[2]+1)
    loop[pos[2], pos[1]] = true
    dir = "S"
    last_pipe = "S"

    while field[pos[2], pos[1]] != 'S'
        """
        '|'  => Counts
        '-'  => Never Counts
        'L--J' => Counts 2
        'F--7' => Counts 2
        'F--J' => Counts 1
        'L--7' => Counts 1
        """
        pipe = field[pos[2], pos[1]]
        if pipe in ('|', 'L', 'F')
            loop[pos[2], pos[1]] = true
        end
   
        if pipe == 'J' && last_pipe == 'L'
            loop[pos[2], pos[1]] = true
        end

        if pipe == '7' && last_pipe == 'F'
            loop[pos[2], pos[1]] = true
        end

        if pipe != '-'
            last_pipe = pipe
        end
            
        pos, dir = get_next_pos(field, pos, dir)
    end
    return loop
end

start_pos = get_start_pos(field)
loop = create_loop(field, start_pos)
odd(x) = x % 2 == 1

inside_loop = 0

for y in 1:size(field, 1)
    for x in 1:size(field, 2)
        loop[y, x] && continue
        field[y, x] != '.' && continue
        if odd(sum(loop[x:end, y]))
            inside_loop += 1
        end
    end
end
        
inside_loop