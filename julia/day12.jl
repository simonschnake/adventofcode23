input = readlines("inputs/day12")

function parse_line(line)
    a, b = split(line, " ")
    b = parse.(Int, split(b, ","))
    return a, b
end

function count_in_str(s)
    ans = Int[]
    count = 0
    for i in 1:length(s)
        if s[i] == '#'
            count += 1
        elseif count > 0
            push!(ans, count)
            count = 0
        end
    end
    if count > 0
        push!(ans, count)
    end
    return ans
end
        
function equal_beginning(arr1, arr2)
    l = length(arr1)
    l == 0 && return true
    l > length(arr2) && return false # arr1 is longer than arr2
    return arr1[1:l] == arr2[1:l]
end

function count_possible_strings(s, counts, memo)
    if occursin('?', s) == false
        if count_in_str(s) == counts
            return 1
        else
            return 0
        end
    end

    idx = findfirst('?', s)
    idx = findlast('.', s[1:idx-1])    
    if isnothing(idx)
        idx = 0
    end

    c = count_in_str(s[1:idx])
    if equal_beginning(c, counts) == false
        return 0
    end

    if (idx, c) in keys(memo)
        return memo[(idx, c)]
    end

    x = (
        count_possible_strings(
            replace(s, '?' => '.', count=1),
            counts,
            memo)
         + 
        count_possible_strings(
            replace(s, '?' => '#', count=1),
            counts,
            memo
        ))
    memo[(idx, c)] = x

    return x
end

# Part 1
map(input) do line
    a, b = parse_line(line)
    memo = Dict{Tuple{Int, Vector{Int}}, Int}()
    count_possible_strings(a, b, memo)
end |> sum

# Part 2
map(input) do line
    a, b = parse_line(line)
    a = repeat(a * "?", 5)[1:end-1]
    b = repeat(b, 5)
    memo = Dict{Tuple{Int, Vector{Int}}, Int}()
    count_possible_strings(a, b, memo)
end |> sum