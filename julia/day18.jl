input = read("inputs/day18", String)
input = """
R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)
"""

const UP = -1im; const DOWN = 1im; const RIGHT = 1+0im; const LEFT = -1+0im

function parse_input(input)
    input = split(input, "\n")
    input = filter(x -> !isempty(x), input)
    pattern = r"([RDLU])\s+(\d+)\s+\(#([0-9a-fA-F]{6})\)"
    matches = match.(pattern, input) .|> x -> x.captures
    dirs = getindex.(getindex.(matches, 1), 1)
    dirs_a = map(x -> x == 'R' ? RIGHT : x == 'L' ? LEFT : x == 'U' ? UP : DOWN, dirs)
    dists_a = parse.(Int, getindex.(matches, 2))
    colors = getindex.(matches, 3)
    dists_b = colors .|> x -> x[1:end-1] .|> x -> parse(Int, x, base=16)
    dirs_b = colors .|> x -> x[end] == '0' ? RIGHT : x[end] == '1' ? DOWN : x[end] == '2' ? LEFT : UP
    return dirs_a, dists_a, dirs_b, dists_b
end

function f(steps, pos=0, ans=1)
    for s in steps
        pos += s.re
        ans += s.im * pos + abs(s)/2
    end
    return Int(ans)
end

dirs_a, dists_a, dirs_b, dists_b = parse_input(input)

f(dirs_a .* dists_a)
f(dirs_b .* dists_b)
