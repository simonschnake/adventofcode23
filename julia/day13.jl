input = read("inputs/day13", String)

function to_field(s)
    s = split(s, "\n")
    s = filter(x -> x != "", s)
    s = collect.(s)
    s = hcat(s...)
    return s
end


function has_reflection_at(field, i)
    s = size(field, 1)

    l = min(i, s-i)

    for j in 1:l
        if field[i-j+1, :] != field[i+j, :]
            return false
        end
    end

    return true
end

field = to_field("""
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.
""")

function reflection_score(field)
    s = size(field, 1)

    ref_col = has_reflection_at.(Ref(field), 1:s-1)
    col = findfirst(ref_col)

    if isnothing(col)
        field = permutedims(field, (2,1))
        s = size(field, 1)
        ref_row = has_reflection_at.(Ref(field), 1:s-1)
        row = findfirst(ref_row)
        if isnothing(row)
            return 0
        else
            return 100 * row
        end
    else
        return col
    end
end
    
reflection_score.(fields) |> sum

# 2nd part


function has_reflection_with_smudge_at(field, i)
    s = size(field, 1)

    l = min(i, s-i)

    diff = 0

    for j in 1:l
        diff += sum(field[i-j+1, :] .!= field[i+j, :])
        if diff > 1
            return false
        end
    end

    if diff == 1
        return true
    else
        return false
    end
end

field = permutedims(field, (2,1))
has_reflection_with_smudge_at.(Ref(field), 1:size(field, 1)-1)


function reflection_with_smudge_score(field)
    s = size(field, 1)

    ref_col = has_reflection_with_smudge_at.(Ref(field), 1:s-1)
    col = findfirst(ref_col)

    if isnothing(col)
        field = permutedims(field, (2,1))
        s = size(field, 1)
        ref_row = has_reflection_with_smudge_at.(Ref(field), 1:s-1)
        row = findfirst(ref_row)
        if isnothing(row)
            return 0
        else
            return 100 * row
        end
    else
        return col
    end
end

reflection_with_smudge_score.(fields) |> sum
