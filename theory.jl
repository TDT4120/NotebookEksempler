#checkboxes
using LightGraphs
using GraphPlot
using DataStructures
using Colors
G = DiGraph(4)
E = [
    (1, 2, 8),
    (1, 3, 4),
    (2, 4, 6),
    (3, 2, 5),
    (3, 4, 2)
]

C = zeros(Int, nv(G), nv(G))

for e in E
    u, v, c = e
    add_edge!(G, u, v)
    C[u, v] = c
end
F = [
    0 4 4 0
    0 0 0 6
    0 2 0 2
    0 0 0 0
]

E2 = [
    (1, 2, 3),
    (1, 3, 1),
    (2, 4, 2),
    (2, 3, 2),
    (3, 4, 2)
]

G2 = DiGraph(4)
C2 = zeros(Int, nv(G), nv(G))
for e in E2
    u, v, c = e
    add_edge!(G2, u, v)
    C2[u, v] = c
end
F2 = [
    0 3 1 0
    0 0 0 1
    0 0 0 3
    0 0 0 0
]

function draw_network(G, E, F, C)
    locs_x = Vector{Float32}([0, 1, 1, 2])
    locs_y = Vector{Float32}([1, 0, 2, 1])

    IJulia.clear_output(true)
    display(gplot(G, locs_x, locs_y, nodelabel=1:nv(G), edgelabel=["$(F[t[1], t[2]]) / $(C[t[1], t[2]])"  for t in E]))

    sleep(1)
end

#draw_network(G, E, F)
println(F)
