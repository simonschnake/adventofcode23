input = read("inputs/day19", String)

input = """
px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}
"""

instructions, values = split.(split(input, "\n\n"), "\n")
instructions = filter!(x -> !isempty(x), instructions)
values = filter!(x -> !isempty(x), values)


function parse_instruction(instruction)

    name, conditions_str = split(instruction, '{')
    name = Symbol(name)

    # Remove the closing curly brace and split the conditions
    conditions_str = conditions_str[1:end-1]  # Remove the '}' at the end
    conditions = split(conditions_str, ',')
    default_case = Symbol(conditions[end])

    # Parse each condition
    parsed_conditions = []
    for condition in conditions[1:end-1]
        # Split the condition into its parts
        condition, res = split(condition, ':')
        var = condition[1] |> Symbol
        if condition[2] == '<'
            comp = <
        elseif condition[2] == '>'
            comp = >
        else
            error("Unknown comparison operator: $(condition[2])")
        end
        val = parse(Int, condition[3:end])
        push!(parsed_conditions, (var=var, comp=comp, val=val, res=Symbol(res)))
    end

    return name => (conditions=parsed_conditions, default_case=default_case)
end

instructions = Dict(parse_instruction.(instructions))

values = map(values) do val
    replace(val, "{"=>"(", "}"=>")") |> Meta.parse |> eval
end

function eval_instr(instr, val)
    for condition in instr.conditions
        if condition.comp(val[condition.var], condition.val)
            return condition.res
        end
    end
    return instr.default_case
end

function answer(val, instr_name=:in)
    instr = instructions[instr_name]
    res = eval_instr(instr, val)
    if res == :R # reject
        return nothing
    elseif res == :A # accept
        return instr_name
    end
    return answer(val, res)
end


rating(val) = sum(val[p] for p in propertynames(val))

filter(v -> answer(v) != nothing, values) .|> rating |> sum

# Part 2

function Base.:<(r::UnitRange{Int64}, i::Int64)
    return first(r):(i-1), i:last(r)
end

function Base.:>(r::UnitRange{Int64}, i::Int64)
    return (i+1):last(r), first(r):i
end

function new_tuple(old_tuple, var, val)
    return (
        x = var == :x ? val : old_tuple.x,
        m = var == :m ? val : old_tuple.m,
        a = var == :a ? val : old_tuple.a,
        s = var == :s ? val : old_tuple.s,
    )
end
    

function is_empty(t::NamedTuple)
    ls = [length(t[x]) for x in propertynames(t)]
    return any(ls .== 0)
end


function next(ps)
    new_ps = []
    for p in ps
        instr = instructions[p[1]]
        v = p[2]
        for condition in instr.conditions
            t, f = condition.comp(v[condition.var], condition.val)
            t_v = new_tuple(v, condition.var, t)
            v = new_tuple(v, condition.var, f)

            if !is_empty(t_v)
                push!(new_ps, condition.res => t_v)
            end

            if is_empty(v)
                break
            end
        end
        if !is_empty(v)
            push!(new_ps, instr.default_case => v)
        end
    end
    return new_ps
end

ps = [:in => (x = 1:4000, m = 1:4000, a = 1:4000, s = 1:4000)]
res = []
while !isempty(ps)
    ps = next(ps)
    append!(res, getindex.(filter(x -> x[1] == :A, ps), 2))
    ps = filter(x -> x[1] != :A && x[1] != :R, ps)
end
res

combinations(r) = prod(length(r[p]) for p in propertynames(r))

combinations.(res) |> sum
