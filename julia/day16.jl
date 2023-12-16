input = read("inputs/day16", String)

input = """
.|...\\....
|.-.\\.....
.....|-...
........|.
..........
.........\\
..../.\\\\..
.-.-/..|..
.|....-|.\\
..//.|....
"""

function to_field(s)
    s = split(s, "\n")
    s = filter(x -> x != "", s)
    s = collect.(s)
    s = hcat(s...)
    return s
end


direction = Dict(
    :north => CartesianIndex(0, -1),
    :south => CartesianIndex(0, 1),
    :east => CartesianIndex(1, 0),
    :west => CartesianIndex(-1, 0),
)

elements = Dict(
    '.' => Dict(
        :north => [:north],
        :south => [:south],
        :east => [:east],
        :west => [:west],
    ),
    '\\' => Dict(
        :north => [:west],
        :south => [:east],
        :east => [:south],
        :west => [:north],
    ),
    '/' => Dict(
        :north => [:east],
        :south => [:west],
        :east => [:north],
        :west => [:south],
    ),
    '|' => Dict(
        :north => [:north],
        :south => [:south],
        :east => [:north, :south],
        :west => [:north, :south],
    ),
    '-' => Dict(
        :north => [:east, :west],
        :south => [:east, :west],
        :east => [:east],
        :west => [:west],
    ),
)

struct Beam
    pos::CartesianIndex{2}
    dir::Symbol
end

function outside(field, beam)
    !checkbounds(Bool, field, beam.pos)
end

function next(beam::Beam, field)
    if outside(field, beam)
        return nothing
    end

    elem = field[beam.pos]

    directions = elements[elem][beam.dir]

    return [
        Beam(beam.pos + direction[dir], dir)
        for dir in directions
    ]
end


function energiezed(field, start_beam)

    beams = [start_beam]

    all_beams = Set{Beam}()

    while !isempty(beams)
        all_beams = union(all_beams, beams)

        beams = next.(beams, Ref(field)) 
        beams = vcat(beams...) 
        beams = filter(x -> !isnothing(x), beams)
        beams = filter(x -> !(x in all_beams), beams)
    end 

    Set(filter(x -> !outside(field, x), all_beams) .|> x -> x.pos) |> length
end

# Part 1

field = to_field(input)

energiezed(field, Beam(CartesianIndex(1, 1), :east))

# Part 2

east_beams = [Beam(CartesianIndex(1, i), :east) for i in 1:size(field, 2)]
west_beams = [Beam(CartesianIndex(size(field, 1), i), :west) for i in 1:size(field, 2)]
north_beams = [Beam(CartesianIndex(i, size(field, 2)), :north) for i in 1:size(field, 1)]
south_beams = [Beam(CartesianIndex(i, 1), :south) for i in 1:size(field, 1)]

beams = [east_beams; west_beams; north_beams; south_beams]

energiezed.(Ref(field), beams) |> maximum