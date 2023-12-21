using Images

const DIR = (CartesianIndex(0, -1), CartesianIndex(0, 1), CartesianIndex(1, 0), CartesianIndex(-1, 0))
const UP = 1; const DOWN = 2; const RIGHT = 3; const LEFT = 4

function to_field(field)
    field = split(field, "\n")
    field = filter(x -> x != "", field)
    field = collect.(field)
    field = hcat(field...)
    start = first(CartesianIndices(field)[field .== 'S'])
    field = field .!= '#'
    return start, field
end

function in_field(pos, field)
    return field[CartesianIndex(
        mod1(pos[1], size(field, 1)),
        mod1(pos[2], size(field, 2))
    )]
end

function possible_next_pos(pos, field)
    possible_pos = [pos + dir for dir in DIR]
    possible_pos = filter(x -> in_field(x, field), possible_pos)
    return possible_pos
end
    
function walk(position, steps, field, )
    positions = [position]
    for _ in 1:steps
        
        positions = reduce(vcat, [possible_next_pos(pos, field) for pos in positions])
        positions = unique(positions)
    end
    return positions
end

function solve(input, steps)
    start, field = to_field(input)
    walk(start, steps, field) |> length
end

test_input = """
...........
.....###.#.
.###.##..#.
..#.#...#..
....#.#....
.##..S####.
.##..#...#.
.......##..
.##.#.####.
.##..##.##.
...........
"""
input = read("inputs/day21", String)

@assert solve(test_input, 6) == 16
@assert solve(test_input, 10) == 50
@assert solve(test_input, 50) == 1594
@assert solve(test_input, 100) == 6536
@assert solve(test_input, 500) == 167004
##@assert solve(test_input, 1000) == 668697
## @assert solve(test_input, 5000) == 16733044

solve(input, 64)

# Part 2

s, f = to_field(input)

s
size(f)
# size = (131, 131)
# s = (66, 66) <- center

# plot the field

function steps_inside(start, steps, field)
    steps = walk(start, steps, field) 
    return filter(x -> checkbounds(Bool, field, x), steps)
end

steps_1 = steps_inside(CartesianIndex(66, 66), 131+65, f)
steps_2 = steps_inside(CartesianIndex(66, 66), 2*131+65, f)
steps_3 = steps_inside(CartesianIndex(66, 66), 3*131+65, f)
Set(steps_3) == Set(steps_1) 

function plot_steps(steps, field)
    m = fill(RGB(1, 1, 1), size(field)...)
    m[steps] .= RGB(1, 0, 0)
    m[field .== 0] .= RGB(0, 0, 0)
    return m
end

s = Dict()


s[(0, 0)] = steps_inside(CartesianIndex(66, 66), 131, f)
s[(1, 0)] = steps_inside(CartesianIndex(1, 66), 65, f)
s[(-1, 0)] = steps_inside(CartesianIndex(131, 66), 65, f)
s[(0, 1)] = steps_inside(CartesianIndex(66, 1), 65, f)
s[(0, -1)] = steps_inside(CartesianIndex(66, 131), 65, f)
s[(-1, -1)] = []
s[(1, 1)] = []
s[(-1, 1)] = []
s[(1, -1)] = []

p = Dict()

for (k, v) in s
    p[k] = plot_steps(v, f)
end

[
    p[(-1, -1)] p[(-1, 0)] p[(-1, 1)];
    p[(0, -1)] p[(0, 0)] p[(0, 1)];
    p[(1, -1)] p[(1, 0)] p[(1, 1)];
]


# fully filled
s_oddsteps = steps_inside(CartesianIndex(66, 66), 3*131, f)
s_evensteps = steps_inside(CartesianIndex(66, 66), 2*131, f)


# diamonds extremes
s_corner_top = steps_inside(CartesianIndex(1, 66), 131-1, f)
s_corner_bot = steps_inside(CartesianIndex(131, 66), 131-1, f)
s_corner_lef = steps_inside(CartesianIndex(66, 1), 131-1, f)
s_corner_rig = steps_inside(CartesianIndex(66, 131), 131-1, f)

# smaller lateral
s_side_lef_bot_small = steps_inside(CartesianIndex(131, 1), 65-1, f)
s_side_rig_bot_small = steps_inside(CartesianIndex(1, 1), 65-1, f)
s_side_lef_top_small = steps_inside(CartesianIndex(131, 131), 65-1, f)
s_side_rig_top_small = steps_inside(CartesianIndex(1, 131), 65-1, f)


# larger lateral 
s_side_lef_bot_big = steps_inside(CartesianIndex(131, 1), 131+65-1, f)
s_side_rig_bot_big = steps_inside(CartesianIndex(1, 1), 131+65-1, f)
s_side_lef_top_big = steps_inside(CartesianIndex(131, 131), 131+65-1, f)
s_side_rig_top_big = steps_inside(CartesianIndex(1, 131), 131+65-1, f)

p = Dict()

p[(0, 0)] = plot_steps(s_oddsteps, f)
p[(1, 0)] = plot_steps(s_evensteps, f)
p[(-1, 0)] = plot_steps(s_evensteps, f)
p[(0, 1)] = plot_steps(s_evensteps, f)
p[(0, -1)] = plot_steps(s_evensteps, f)

p[(2, 0)] = plot_steps(s_corner_top, f)
p[(-2, 0)] = plot_steps(s_corner_bot, f)
p[(0, 2)] = plot_steps(s_corner_lef, f)
p[(0, -2)] = plot_steps(s_corner_rig, f)

p[(-2, 1)] = plot_steps(s_side_lef_bot_small, f)
p[(-1, 2)] = plot_steps(s_side_lef_bot_small, f)
p[(1, 2)] = plot_steps(s_side_rig_bot_small, f)
p[(2, 1)] = plot_steps(s_side_rig_bot_small, f)

p[(-2, -1)] = plot_steps(s_side_lef_top_small, f)
p[(-1, -2)] = plot_steps(s_side_lef_top_small, f)
p[(2, -1)] = plot_steps(s_side_rig_top_small, f)
p[(1, -2)] = plot_steps(s_side_rig_top_small, f)

p[(-1, 1)] = plot_steps(s_side_lef_bot_big, f)
p[(-1, -1)] = plot_steps(s_side_lef_top_big, f)
p[(1, 1)] = plot_steps(s_side_rig_bot_big, f)
p[(1, -1)] = plot_steps(s_side_rig_top_big, f)

p[(-2, 2)] = plot_steps([], f)
p[(2, -2)] = plot_steps([], f)
p[(2, 2)] = plot_steps([], f)
p[(-2, -2)] = plot_steps([], f)

[
    p[(-2, -2)] p[(-2, -1)] p[(-2, 0)] p[(-2, 1)] p[(-2, 2)];
    p[(-1, -2)] p[(-1, -1)] p[(-1, 0)] p[(-1, 1)] p[(-1, 2)];
    p[(0, -2)] p[(0, -1)] p[(0, 0)] p[(0, 1)] p[(0, 2)];
    p[(1, -2)] p[(1, -1)] p[(1, 0)] p[(1, 1)] p[(1, 2)];
    p[(2, -2)] p[(2, -1)] p[(2, 0)] p[(2, 1)] p[(2, 2)];
]

nsteps = 26501365

romboid_width = ( nsteps - 65 ) ÷ 131

nfull_odd  =  ( romboid_width ÷ 2 * 2 - 1 )^2
nfull_even =  ( romboid_width ÷ 2 * 2    )^2

nodd = length(s_oddsteps)
neven = length(s_evensteps)

ncorners = length(s_corner_top)+length(s_corner_bot)+length(s_corner_lef)+length(s_corner_rig)
nsides_small = length(s_side_lef_bot_small)+length(s_side_rig_bot_small)+length(s_side_lef_top_small)+length(s_side_rig_top_small)
nsides_large = length(s_side_lef_bot_big)  +length(s_side_lef_top_big)  +length(s_side_rig_bot_big)  +length(s_side_rig_top_big)

total = nfull_odd*nodd + nfull_even*neven + romboid_width*nsides_small + (romboid_width-1)*nsides_large + ncorners

print("Total plots = $total")
