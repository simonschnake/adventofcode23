using StatsBase
input = readlines("inputs/day7")

input = split("""32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483""", "\n")

card = Dict(c => i for (i, c) in enumerate("23456789TJQKA"))

function calc_type(line)
    occ = values(countmap(line))
    occ = sort(occ, rev=true)
    occ == [5] && return 7 # Five of a kind
    occ == [4, 1] && return 6 # Four of a kind
    occ == [3, 2] && return 5 # Full house
    occ == [3, 1, 1] && return 4 # Three of a kind
    occ == [2, 2, 1] && return 3 # Two pairs
    occ == [2, 1, 1, 1] && return 2 # One pair
    occ == [1, 1, 1, 1, 1] && return 1 # High card
    error("Unknown type")
end

struct Hand
    hand::Array{Int, 1}
    raw::String
    bid::Int
    type::Int
end

function Hand(line)
    hand_str, bid_str = split(line, " ")
    hand = [card[c] for c in hand_str]
    bid = parse(Int, bid_str)
    type = calc_type(hand)
    @show hand, bid, type
    return Hand(hand, line, bid, type)
end

function Base.isless(h1::Hand, h2::Hand)
    if h1.type == h2.type
        return h1.hand < h2.hand
    end
    return h1.type < h2.type
end

hands = Hand.(input)
hands = sort(hands, rev=true)

[hand.bid * i for (i, hand) in enumerate(reverse(hands))] |> sum


## Part 2
cardb = Dict(c => i for (i, c) in enumerate("J23456789TQKA"))

function calc_type_b(hand)
    jokers = count(==(1), hand)
    hand = filter(!=(1), hand)
    occ = values(countmap(hand))
    occ = sort(occ, rev=true)
    occ == [5] && return 7 # Five of a kind
    occ == [4, 1] && return 6 # Four of a kind
    occ == [3, 2] && return 5 # Full house
    occ == [3, 1, 1] && return 4 # Three of a kind
    occ == [2, 2, 1] && return 3 # Two pairs
    occ == [2, 1, 1, 1] && return 2 # One pair
    occ == [1, 1, 1, 1, 1] && return 1 # High card
   
    # 1 joker
    occ == [4] && return 7 # Five of a kind
    occ == [3, 1] && return 6 # Four of a kind
    occ == [2, 2] && return 5 # Full house
    occ == [2, 1, 1] && return 4 # Three of a kind
    occ == [1, 1, 1, 1] && return 2 # One pair

    # 2 jokers
    occ == [3] && return 7 # Five of a kind
    occ == [2, 1] && return 6 # Four of a kind
    occ == [1, 1, 1] && return 4 # Three of a kind

    # 3 jokers
    occ == [2] && return 7 # Five of a kind
    occ == [1, 1] && return 6 # Four of a kind

    # 4 jokers
    occ == [1] && return 7 # Five of a kind

    # 5 jokers
    return 7 # Five of a kind

    error("Unknown type")
end

struct HandB
    hand::Array{Int, 1}
    raw::String
    bid::Int
    type::Int
end

function HandB(line)
    hand_str, bid_str = split(line, " ")
    hand = [cardb[c] for c in hand_str]
    bid = parse(Int, bid_str)
    type = calc_type_b(hand)
    @show hand, bid, type
    return HandB(hand, line, bid, type)
end

function Base.isless(h1::HandB, h2::HandB)
    if h1.type == h2.type
        return h1.hand < h2.hand
    end
    return h1.type < h2.type
end

hands = HandB.(input)
hands = sort(hands, rev=true)

[hand.bid * i for (i, hand) in enumerate(reverse(hands))] |> sum