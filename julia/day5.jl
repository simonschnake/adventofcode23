input = read("inputs/day5", String)[1:end-1]

input = """seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"""

inputs = split(input, "\n\n")

seeds = eachmatch(r"\d+", split(inputs[1], ": ")[2]) .|> x -> x.match .|> x -> parse(Int, x)

struct SDRange
    range::UnitRange{Int}
    offset::Int
end

function SDRange(source_range_start, destination_range_start, range_length) 
    range = source_range_start:(source_range_start + range_length - 1)
    offset = destination_range_start - source_range_start
    return SDRange(range, offset)
end

function get_destination(source, map)
    for r in map
        if source in r.range
            return source + r.offset
        end
    end
    return source
end

maps = map(inputs[2:end]) do input
    map(split(input, "\n")[2:end]) do line
        @show line
        destination_range_start, source_range_start, range_length = eachmatch(r"\d+", line) .|> x -> x.match .|> x -> parse(Int, x)
        SDRange(source_range_start, destination_range_start, range_length)
    end
end

map(seeds) do x
    for m in maps
        x = get_destination(x, m)
    end
    x
end |> minimum

# Part 2

function parse_input(input::AbstractString)
    blocks = split(rstrip(input), "\n\n")
    seeds = parse.(Int, split(strip(split(blocks[1], ":")[2]), " "))
    data = Dict{Tuple{String,String},Matrix{Int}}()
    for block ∈ blocks[2:end]
        lines = split(block, "\n")
        m = match(r"([a-z]+)\-to\-([a-z]+).+", lines[1])
        temp = []
        for line in lines[2:end]
            push!(temp, parse.(Int, split(line, " "))')
        end
        data[(m[1], m[2])] = vcat(temp...)
    end
    return seeds, data
end

function perform_mapping(data::Dict{Tuple{String,String},Matrix{Int}}, source::String, destination::String, number::Int)
    M = data[(source, destination)]
    for row ∈ axes(M, 1)
        if number ∈ M[row, 2]:M[row, 2]+M[row, 3]-1
            return number - M[row, 2] + M[row, 1]
        end
    end
    return number
end

function perform_mapping(data::Dict{Tuple{String,String},Matrix{Int}}, source::String, destination::String, numbers::Set{UnitRange{Int}})
    M = data[(source, destination)]
    newset = Set{UnitRange{Int}}()
    while !isempty(numbers)
        mapped = false
        ran = pop!(numbers)
        for row ∈ axes(M, 1)
            inter = intersect(ran, M[row, 2]:M[row, 2]+M[row, 3]-1)
            if !isempty(inter)
                mapped = true
                push!(newset, inter[1] - M[row,2] + M[row,1] : inter[end] - M[row,2] + M[row,1])
                left = ran[1]:inter[1]-1
                isempty(left) || push!(numbers, left)
                right = inter[end]+1:ran[end]
                isempty(right) || push!(numbers, right)
                break
            end
        end
        mapped || push!(newset, ran)
    end
    return newset
end

function part1(seeds::Vector{Int}, data::Dict{Tuple{String,String},Matrix{Int}})
    locations = Set{Int}()
    chain = ("seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location")
    for number ∈ seeds
        for (src, dest) ∈ zip(chain[1:end-1], chain[2:end])
            number = perform_mapping(data, src, dest, number)
        end
        push!(locations, number)
    end
    return minimum(locations)
end

function part2(seeds::Vector{Int}, data::Dict{Tuple{String,String},Matrix{Int}})
    locations = Set{UnitRange{Int}}()
    chain = ("seed", "soil", "fertilizer", "water", "light", "temperature", "humidity", "location")
    seedstarts = seeds[1:2:end]
    seedlengths = seeds[2:2:end]
    for (ss, sl) ∈ zip(seedstarts, seedlengths)
        numbers = Set([ss:ss+sl-1])
        for (src, dest) ∈ zip(chain[1:end-1], chain[2:end])
            numbers = perform_mapping(data, src, dest, numbers)
        end
        push!(locations, numbers...)
    end
    return minimum(x -> x[1], locations)
end


seeds, data = parse_input(input)
@show part1(seeds, data)
@show part2(seeds, data)