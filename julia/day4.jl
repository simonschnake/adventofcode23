# Read input from file
inputs = readlines("inputs/day4")
line = inputs[1]


function parse_card_string(s::String)
    # Regular expression to match numbers
    pattern = r"(\d+)"

    # Removing the "Card X:" part
    s = replace(s, r"Card\s+\d+:\s*" => "")

    # Splitting the string at the "|"
    parts = split(s, " | ")

    # Extracting numbers from each part
    list1 = [parse(Int, m.match) for m in eachmatch(pattern, parts[1])]
    list2 = [parse(Int, m.match) for m in eachmatch(pattern, parts[2])]

    set1, set2 = Set(list1), Set(list2)
    return length(set1 ∩ set2)
end

matches = parse_card_string.(inputs)

counts = filter(x -> x > 0, matches)

2 .^ (counts .- 1) |> sum

# Part 2

cards = ones(Int, length(inputs))

for (i, m) in enumerate(matches)
    c = cards[i]
    for j in i+1:i+m
        cards[j] += c
    end
end

cards |> sum
