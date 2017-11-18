using LightGraphs
using GraphPlot
using DataStructures
using Colors
using GR

source, sink = 1, 6
G = DiGraph(6)
E = [
    (1, 2, 16),
    (1, 3, 13),
    (3, 2, 4),
    (2, 4, 12),
    (4, 3, 9),
    (3, 5, 14),
    (4, 6, 20),
    (5, 4, 7),
    (5, 6, 4)
]

sort!(E)
C = zeros(Int, nv(G), nv(G))

for e in E
    u, v, c = e
    add_edge!(G, u, v)
    C[u, v] = c
end

F = zeros(C)

function draw_network(G, E, F)
    locs_x = Vector{Float32}([0, 1, 1, 2, 2, 3])
    locs_y = Vector{Float32}([1, 0, 2, 0, 2, 1])

    IJulia.clear_output(true)
    display(gplot(G, locs_x, locs_y, nodelabel=1:nv(G), edgelabel=["$(F[t[1], t[2]]) / $(C[t[1], t[2]])"  for t in E]))

    sleep(1)
end

function draw_initial_network()
    draw_network(G, E, F)
end

println("Praksisrammeverk importert. Beep boop")
