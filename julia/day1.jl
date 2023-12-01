
filename = "inputs/day1"
lines = readlines(filename)

function is_digit(c)
    return c in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
end

l = filter.(is_digit, lines)
fc = first.(l)
lc = last.(l)

parse.(Int,fc .* lc) |> sum


# Part 2

numbers = Dict(
    "one" => 1,
    "two" => 2,
    "three" => 3,
    "four" => 4,
    "five" => 5,
    "six" => 6,
    "seven" => 7,
    "eight" => 8,
    "nine" => 9,
    "9" => 9,
    "8" => 8,
    "7" => 7,
    "6" => 6,
    "5" => 5,
    "4" => 4,
    "3" => 3,
    "2" => 2,
    "1" => 1,
)

function find_first(str)
    l = length(str)
    for i in 1:l
        for ns in keys(numbers)
            if startswith(str[i:end], ns)
                return numbers[ns]
            end
        end
    end
end

function find_last(str)
    l = length(str)
    for i in l:-1:1
        for ns in keys(numbers)
            if endswith(str[1:i], ns)
                return numbers[ns]
            end
        end
    end
end

sum(find_first.(lines)*10 .+ find_last.(lines))
