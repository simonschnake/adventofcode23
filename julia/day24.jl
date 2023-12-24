input = read("inputs/day24", String)

test_input = """
19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3
"""

lines = split(input, "\n") |> xs -> filter(x -> x != "", xs)

hailstones = map(lines) do line
    line = replace(line, " @ " => ", ")
    line = split(line, ", ")
    line = parse.(Int, line)
    (px = line[1], py = line[2], pz = line[3], vx = line[4], vy = line[5], vz = line[6])
end

combinations = []

for i in 1:length(hailstones)
    for j in (i+1):length(hailstones)
        push!(combinations, (i, j))
    end
end

combinations


function cross_point(h1, h2)
    px1, py1, pz1, vx1, vy1, vz1 = h1.px, h1.py, h1.pz, h1.vx, h1.vy, h1.vz
    px2, py2, pz2, vx2, vy2, vz2 = h2.px, h2.py, h2.pz, h2.vx, h2.vy, h2.vz

    t1 = vx2 / (vy2 * vx1 - vy1 * vx2) * (py1 - py2 - (px1 - px2) * vy2 / vx2) 
    t2 = (px1 - px2)/vx2 + vx1/vx2 * t1

    x = px1 + vx1 * t1
    y = py1 + vy1 * t1
    z1 = pz1 + vz1 * t1
    z2 = pz2 + vz2 * t2

    return (t1=t1, t2=t2, x=x, y=y, z1=z1, z2=z2)
end

function intersects(i, j, lower, higher)
    h1 = hailstones[i]
    h2 = hailstones[j]

    t1, t2, x, y, z1, z2 = cross_point(h1, h2)
    
    !isfinite(t1) && return false
    !isfinite(t2) && return false
    t1 < 0 && return false
    t2 < 0 && return false
    x < lower && return false
    y < lower && return false
    x > higher && return false
    y > higher && return false

    return true
end

c1 = (x -> x[1]).(combinations)
c2 = (x -> x[2]).(combinations)

intersects.(c1, c2, 200000000000000, 400000000000000) |> sum