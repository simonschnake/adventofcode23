input = readlines("inputs/day11")

input = permutedims(hcat(collect.(input)...), [2, 1])

kart = zeros(Bool, size(input))

kart[input .== '#'] .= true

empty_cols = (1:140)[sum.(eachcol(kart)) .== 0]
empty_rows = (1:140)[sum.(eachrow(kart)) .== 0]

galaxies = findall(kart)

distances = zeros(Int, length(galaxies), length(galaxies))
factor = 2

for i in 1:length(galaxies)
    for j in 1:length(galaxies)
        min_col = min(galaxies[i][1], galaxies[j][1])
        max_col = max(galaxies[i][1], galaxies[j][1])
        min_row = min(galaxies[i][2], galaxies[j][2])
        max_row = max(galaxies[i][2], galaxies[j][2])
        height = max_row - min_row + (factor - 1) * length((min_row:max_row) ∩ empty_rows)
        width = max_col - min_col + (factor - 1) * length((min_col:max_col) ∩ empty_cols)
        distances[i, j] = height + width
    end
end

sum(distances) ÷ 2

global min_dist = Inf

collect(1:442)[[1:2-1; 2+1:end]]

function add_distances(idx, dist)
    global min_dist
    if dist > min_dist
        return
    end
    if length(idx) == 2
        dist = dist + distances[idx[1], idx[2]]
        if dist < min_dist
            @show dist
            global min_dist = dist
        end
        return
    end
    for i in 1:length(idx)
        idx2 = idx[[1:i-1; i+1:end]]
        for j in 1:length(idx2)
            idx3 = idx2[[1:j-1; j+1:end]]
            add_distances(idx3, dist + distances[idx[i], idx2[j]])
        end
    end
end

add_distances(1:length(galaxies), 0)

distances



map(galaxies) do galaxy
    min_dist = Inf
    for galaxy2 in galaxies
        if galaxy == galaxy2
            continue
        end
        dist = abs(galaxy[1] - galaxy2[1]) + abs(galaxy[2] - galaxy2[2])
        min_dist = min(dist, min_dist)
    end
    min_dist
end |> sum


part1(lines) = solve(lines, 2)
part2(lines) = solve(lines, 1_000_000)

function solve(lines, factor)
  grid, galaxies, emptyrows, emptycols = parseinput(lines)
  map(enumerate(galaxies)) do (i, g)
    [dist(g, x, emptyrows, emptycols, factor) for x in galaxies[i+1:end]]
  end |> Iterators.flatten |> sum
end

function dist(a, b, emptyrows, emptycols, factor)
  arow, acol = Tuple(a)
  brow, bcol = Tuple(b)
  minrow, maxrow = minmax(arow, brow)
  mincol, maxcol = minmax(acol, bcol)
  height = maxrow - minrow + (factor-1) * length((minrow:maxrow) ∩ emptyrows)
  width = maxcol - mincol + (factor-1) * length((mincol:maxcol) ∩ emptycols)
  width + height
end

function parseinput(lines)
  grid = reduce(hcat, [collect(line) for line in lines])
  galaxies = findall(==('#'), grid)
  emptyrows = findall(x -> all(==('.'), x), eachrow(grid))
  emptycols = findall(x -> all(==('.'), x), eachcol(grid))
  grid, galaxies, emptyrows, emptycols
end

part1(input)
part2(input)