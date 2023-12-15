inputs = read("inputs/day15", String)
inputs = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

function hash_val(x, y)
    ans = x + y
    ans = ans * 17
    ans = ans % 256
    return ans
end

function hash_fn(s)
    xs = Int.(collect(s))
    foldl(hash_val, xs, init=0)
end

hash_fn.(split(inputs, ",")) |> sum

# Part 2


function collect_boxes(input)
    boxes = [Vector{Tuple{String, Int}}() for _ in 1:256]

    for x in split(inputs, ",")
        if x[end] == '-'
            s = x[1:end-1]
            h = hash_fn(s)
            idx = findfirst(b -> b[1] == s, boxes[h+1])
            if !isnothing(idx)
                deleteat!(boxes[h+1], idx)
            end
        else
            a, b = split(x, "=")
            h = hash_fn(a)
            val = parse(Int, b)
            idx = findfirst(b -> b[1] == a, boxes[h+1])
            if isnothing(idx)
                push!(boxes[h+1], (a, val))
            else
                boxes[h+1][idx] = (a, val)
            end
        end
    end
        
    boxes
end

boxes = collect_boxes(inputs)

map(enumerate(boxes)) do (i, box)
    map(enumerate(box)) do (j, entry)
        i * j * entry[2]
    end |> sum
end |> sum



