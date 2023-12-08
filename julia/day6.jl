time_str, distance_str = readlines("inputs/day6")

times = eachmatch(r"\d+", time_str) .|> x -> x.match .|> x -> parse(Int, x)
distances = eachmatch(r"\d+", distance_str) .|> x -> x.match .|> x -> parse(Int, x)

time = times[1]

d = [(time - release_time) * release_time for release_time in 1:time]

sum(d .> distances[1])

time = times[2]

d = [(time - release_time) * release_time for release_time in 1:time]

sum(d .> distances[2])
 
time = times[3]

d = [(time - release_time) * release_time for release_time in 1:time]

sum(d .> distances[3])

time = times[4]

d = [(time - release_time) * release_time for release_time in 1:time]

sum(d .> distances[4])


29 * 19 * 19 * 21

# Part 2

time = parse(Int, foldl(*, string.(times)))
distance = parse(Int, foldl(*, string.(distances)))

d = [(time - release_time) * release_time for release_time in 1:time]

(d .> distance) |> sum
