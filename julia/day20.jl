using DataStructures

function parse_input(input)
    lines = split(input, "\n")
    lines = filter!(x -> !isempty(x), lines)
    map(lines) do line
        sender, receivers = split(line, " -> ")
        receivers_list = split(receivers, ", ")
        if first(sender) == '&'
            sender_type = :conjunction
            sender = Symbol(sender[2:end])
        elseif first(sender) == '%'
            sender_type = :flipflop
            sender = Symbol(sender[2:end])
        else
            sender_type = :normal
            sender = Symbol(sender)
        end

        return sender, sender_type, Symbol.(receivers_list)
    end 
end

mutable struct FlipFlop
    state::Bool
    const receivers::Array{Symbol, 1}
end

function FlipFlop(receivers)
    return FlipFlop(false, receivers)
end

function pulse(flipflop::FlipFlop, high=false)
    if high
        return nothing, nothing
    end
    flipflop.state = !flipflop.state
    return flipflop.state, flipflop.receivers
end

function pulse(flipflop::FlipFlop, sender::Symbol, high=false)
    return pulse(flipflop, high)
end

function pulse(flipflop::FlipFlop, sender::Symbol, strength::Symbol)
    return pulse(flipflop, strength == :high)
end


mutable struct Conjunction
    inputs::Dict{Symbol, Bool}
    const receivers::Array{Symbol, 1}
end

function Conjunction(receivers)
    return Conjunction(Dict{Symbol, Bool}(), receivers)
end

function pulse(conjunction::Conjunction, sender::Symbol, high=false)
    conjunction.inputs[sender] = high

    all(values(conjunction.inputs)) && return false, conjunction.receivers

    return true, conjunction.receivers
end

function pulse(conjunction::Conjunction, sender::Symbol, strength::Symbol)
    return pulse(conjunction, sender, strength == :high)
end


struct Normal
    receivers::Array{Symbol, 1}
end

function pulse(normal::Normal, sender::Symbol, high=false)
    return high, normal.receivers
end

function pulse(normal::Normal, sender::Symbol, strength::Symbol)
    return pulse(normal, sender, strength == :high)
end

function construct_connections(inputs)
    map(inputs) do input
        sender, sender_type, receivers = input
        if sender_type == :flipflop
            return sender => FlipFlop(receivers)
        elseif sender_type == :conjunction
            return sender => Conjunction(receivers)
        else
            return sender => Normal(receivers)
        end
    end |> Dict
end

struct Message
    sender::Symbol
    receiver::Symbol
    high::Bool
end

function pulse(message::Message, connections)
    pulse(connections[message.receiver], message.sender, message.high)
end

function push_button(connections, debug=false)
    pulses = Queue{Message}()
    enqueue!(pulses, Message(:button, :broadcaster, false))
    low_count = 0
    high_count = 0

    while !isempty(pulses)
        message = dequeue!(pulses)
        if debug
            if message.high
                println("$(message.sender) -high-> $(message.receiver)")
            else
                println("$(message.sender) -low-> $(message.receiver)")
            end
        end

        message.high ? high_count += 1 : low_count += 1

        if !haskey(connections, message.receiver)
            continue
        end
        
        high, receivers = pulse(message, connections)
        isnothing(high) && continue
        for receiver in receivers
            enqueue!(pulses, Message(message.receiver, receiver, high))
        end
    end
    return low_count, high_count
end

function reset_connections!(connections)
    for connection in values(connections)
        if isa(connection, FlipFlop)
            connection.state = false
        elseif isa(connection, Conjunction)
            for key in keys(connection.inputs)
                connection.inputs[key] = false
            end
        end
    end
end

function part1(input)
    inputs = parse_input(input)
    connections = construct_connections(inputs)
    for _ in 1:1000
        push_button(connections)
    end
    reset_connections!(connections)
    high_count = 0
    low_count = 0
    for _ in 1:1000
        low, high = push_button(connections)
        low_count += low
        high_count += high
    end
    return low_count * high_count
end


test_input_1 = """
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
"""

test_input_2 = """
broadcaster -> a
%a -> inv, con
&inv -> b
%b -> con
&con -> output
"""

@assert part1(test_input_1) == 32000000
@assert part1(test_input_2) == 11687500

input = read("inputs/day20", String)
part1(input)

# Part 2

function part2(input)
    inputs = parse_input(input)
    connections = construct_connections(inputs)
    for _ in 1:100000
        push_button(connections)
    end
    reset_connections!(connections)
    presses = 0

    rx_in = Dict(k => 0 for k in keys(connections[:bb].inputs))

    while true
        presses += 1
        pulses = Queue{Message}()
        enqueue!(pulses, Message(:button, :broadcaster, false))
        
        if all(values(rx_in) .> 0)
            break
        end

        while !isempty(pulses)
            message = dequeue!(pulses)

            if !haskey(connections, message.receiver)
                continue
            end
            
            high, receivers = pulse(message, connections)
            isnothing(high) && continue

            if :rx in receivers
                for (k, v) in connections[:bb].inputs
                    if v 
                        rx_in[k] = presses
                    end
                end
            end

            for receiver in receivers
                enqueue!(pulses, Message(message.receiver, receiver, high))
            end
        end
    end

    return prod(values(rx_in))
end


part2(input)