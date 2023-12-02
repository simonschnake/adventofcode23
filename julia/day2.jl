# Read input from file
input = readlines("inputs/day2")

function parse_game_string(game_string)
    # Extract the game number
    game_number_match = match(r"Game (\d+):", game_string)
    game_number = game_number_match !== nothing ? parse(Int, game_number_match[1]) : error("No game number found")

    # Split the string into sets
    sets = split(game_string[game_number_match.offset + length(game_number_match.match):end], ";")

    # Process each set
    sets_tuples = []
    for set in sets
        # Find all color and number pairs in the set
        color_number_matches = collect(eachmatch(r"(\d+) (\w+)", set))

        # Convert matches to tuples (number, color) and add to the list
        set_tuple = [(parse(Int, m[1]), m[2]) for m in color_number_matches]
        push!(sets_tuples, set_tuple)
    end

    return game_number, sets_tuples
end


function number_of_possible_game(game_string, allowed_reds::Int, allowed_greens::Int, allowed_blues::Int)
    game_number, sets = parse_game_string(game_string)

    for set in sets
        for (number, color) in set
            if color == "red" && number > allowed_reds
                return 0
            elseif color == "green" && number > allowed_greens
                return 0
            elseif color == "blue" && number > allowed_blues
                return 0
            end
        end
    end

    return game_number
end

map(input) do game_string
    number_of_possible_game(game_string, 12, 13, 14)
end |> sum

## Part 2

function minimal_number_of_rgb(game_string)
    _, sets = parse_game_string(game_string)

    reds = 0
    greens = 0
    blues = 0

    for set in sets
        for (number, color) in set
            if color == "red"
                reds = max(reds, number)
            elseif color == "green"
                greens = max(greens, number)
            elseif color == "blue"
                blues = max(blues, number)
            end
        end
    end

    return reds, greens, blues
end

    
map(input) do game_string
    reds, greens, blues = minimal_number_of_rgb(game_string)
    reds * greens * blues
end |> sum