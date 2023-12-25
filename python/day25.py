import networkx as nx

with open("inputs/day25", "r") as f:
    input = f.read()

test_input = """
jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr
"""

G = nx.Graph()

for line in input.split("\n"):
    if line == "":
        continue
    left, right = line.split(": ")

    for node in right.split(" "):
        G.add_edge(left, node)

cc = nx.spectral_bisection(G)

print(len(cc[0]) * len(cc[1]))