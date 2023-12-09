inputs = readlines("inputs/day9")

function parse_input(line)
    parse.(Int, split(line))
end

function differences(values)
    diffs = Int64[]
    for i in 1:length(values) - 1
        push!(diffs, values[i + 1] - values[i])
    end
    diffs
end

function next_value(line)
    values = Vector{Vector{Int}}()
    push!(values, parse_input(line))
    while any(last(values) .!= 0)
        push!(values, differences(last(values)))
    end
    first.(values), last.(values)
end

ns = next_value.(inputs) 

getindex.(ns, 2) .|> sum |> sum

# Part 2

function calc_prev_element(v)
    v = reverse(v)
    x = first(v)
    for i in 2:length(v)
        x = v[i] - x
    end
    return x
end

getindex.(ns, 1) .|> calc_prev_element |> sum
