inputs = readlines("inputs/day8")

instructions = inputs[1]

inputs = inputs[3:end]

inputs[1]
inputs[1][1:3]
inputs[1][8:10]
inputs[1][13:15]

parse_lr_map(str) = str[1:3] => (str[8:10], str[13:15])

lr_map = Dict(parse_lr_map.(inputs))

i = 1
pos = "AAA"
while pos != "ZZZ"
    for instr in instructions
        # @show i, pos
        if instr == 'R'
            pos = lr_map[pos][2]
        elseif instr == 'L'
            pos = lr_map[pos][1]
        end
        if pos == "ZZZ"
            break
        end
        i += 1
    end
end

i
pos

# Part 2

start_pos = keys(lr_map) |> x -> filter(y -> y[3] == 'A', x) |> collect

function reached_goal(pos)
    for p in pos
        if p[3] != 'Z'
            return false
        end
    end
    return true
end

i = 1
pos = start_pos[1]

const L = length(instructions)
function next(pos, i)
    dir = instructions[i]
    dir == 'R' && return lr_map[pos][2], mod1(i + 1, L)
    dir == 'L' && return lr_map[pos][1], mod1(i + 1, L)
end

function floyd(x0)
    tortoise = next(x0...)
    hare = next(next(x0...)...)

    while tortoise != hare
        tortoise = next(tortoise...)
        hare = next(next(hare...)...)
    end

    start_of_cycle = 0
    tortoise = x0
    while tortoise != hare
        tortoise = next(tortoise...)
        hare = next(hare...)
        start_of_cycle += 1
    end
    
    cycle_length = 1

    hare = next(tortoise...)
    while tortoise != hare
        hare = next(hare...)
        cycle_length += 1
    end

    return start_of_cycle, cycle_length
end


pos = start_pos[6]
start_cycle, cycle_length = floyd((pos, 1))
# go to start of cycle
for _ in 1:start_cycle
    pos, i = next(pos, i)
end
pos


function calc_z_pos(start_pos)
    pos = start_pos
    i = 1
    start_cycle, cycle_length = floyd((pos, i))

    # go to start of cycle
    for _ in 1:start_cycle
        pos, i = next(pos, i)
    end

    z_pos = []
    # find all Zs in cycle
    for j in 1:cycle_length
        pos, i = next(pos, i)
        if pos[3] == 'Z'
            push!(z_pos, j+start_cycle)
        end
    end

    return z_pos[1]
end

cycle_z =  [calc_z_pos(start_pos[i]) for i in 1:6]

lcm(cycle_z...)