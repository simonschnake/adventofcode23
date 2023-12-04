# Read input from file
inputs = readlines("inputs/day3")

inputs = split("""467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...\$.*....
.664.598..""")

function find_numbers(inputs)
    matches = []
    for (i, input) in enumerate(inputs)
        for m in eachmatch(r"\d+", input)
            n = parse(Int, m.match)
            s = length(m.match)
            pos = m.offset
            push!(matches, (i, pos, s, n))
        end
    end
    return matches
end

function is_symbol(c)
    if isdigit(c) || c == '.'
        return false
    end
    return true
end

function is_symbol_neighbor(match, inputs)
    i, pos, s, n = match
    for x in max(1, i - 1):min(length(inputs), i + 1)
        for y in max(1, pos - 1):min(length(inputs[x]), pos + s)
            if is_symbol(inputs[x][y])
                return true
            end
        end
    end
    return false
end

matches = find_numbers(inputs)
matches = matches[is_symbol_neighbor.(matches, Ref(inputs))]
getindex.(matches, 4) |> sum

## Part 2

to_matrix(inputs) = reduce(hcat, collect.(inputs))

input_matrix = to_matrix(inputs)


function parse_number(j, i, direction, input_matrix)
    number = input_matrix[j, i] * "" # Convert to string
    if direction == :left || direction == :both
        x = j - 1
        while x >= 1 && isdigit(input_matrix[x, i])
            number = input_matrix[x, i] * number
            x -= 1
        end
    end
    if direction == :right || direction == :both
        x = j + 1
        while x <= size(input_matrix, 1) && isdigit(input_matrix[x, i])
            number = number * input_matrix[x, i]
            x += 1
        end
    end
    return parse(Int, number)
end


function collect_star_numbers(input_matrix)
    star_numbers = []
    for i in 1:size(input_matrix, 1)
        for j in 1:size(input_matrix, 2)
            if input_matrix[j, i] != '*'
                continue
            end
            # Collect all numbers around the star
            numbers = []
            # Left
            # Only one number is possible
            if (j - 1) >= 1 && isdigit(input_matrix[j-1, i])
                push!(numbers, parse_number(j - 1, i, :left, input_matrix))
            end
            # Right
            # Only one number is possible
            if (j + 1) <= size(input_matrix, 1) && isdigit(input_matrix[j+1, i])
                push!(numbers, parse_number(j + 1, i, :right, input_matrix))
            end
            # Up
            # There are two numbers possible,
            # one on the left and one on the right
            # if the place on top is not a digit
            # else there is only one number possible
            # which can spread to the left and right
            if (i - 1) >= 1
                if !isdigit(input_matrix[j, i-1])
                    if (j - 1) >= 1 && isdigit(input_matrix[j-1, i-1])
                        # Left
                        push!(numbers, parse_number(j - 1, i - 1, :left, input_matrix))
                    end
                    if (j + 1) <= size(input_matrix, 2) && isdigit(input_matrix[j+1, i-1])
                        # Right
                        push!(numbers, parse_number(j + 1, i - 1, :right, input_matrix))
                    end
                else
                    push!(numbers, parse_number(j, i - 1, :both, input_matrix))
                end
            end

            # Down
            # Same as up
            if (i + 1) <= size(input_matrix, 1)
                if !isdigit(input_matrix[j, i+1])
                    if (j - 1) >= 1 && isdigit(input_matrix[j-1, i+1])
                        # Left
                        push!(numbers, parse_number(j - 1, i + 1, :left, input_matrix))
                    end
                    if (j + 1) <= size(input_matrix, 2) && isdigit(input_matrix[j+1, i+1])
                        # Right
                        push!(numbers, parse_number(j + 1, i + 1, :right, input_matrix))
                    end
                else
                    push!(numbers, parse_number(j, i + 1, :both, input_matrix))
                end
            end
            push!(star_numbers, numbers)
        end
    end
    return star_numbers
end

star_numbers = collect_star_numbers(input_matrix)

star_numbers = filter(x -> length(x) == 2, star_numbers)

map(x -> x[1] * x[2], star_numbers) |> sum
