using LightGraphs
using GraphPlot
using DataStructures
using Colors
using GR

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

source, sink = 1, 6
function find_aug_path(G, F, C, source, sink)
    Q = Queue(Int)
    V = falses(nv(G))
    P = Dict{Int, Int}()

    function get_path()
        n = sink
        res = []
        while n != 0
            push!(res, n)
            n = P[n]
        end
        reverse!(res)
    end

    enqueue!(Q, 1)
    P[1] = 0

    while length(Q) > 0
        n = dequeue!(Q)
        if n == sink
            return get_path()
        end
        for nb in all_neighbors(G, n)
            if !V[nb] && F[n, nb] < C[n, nb]
                enqueue!(Q, nb)
                V[nb] = true
                P[nb] = n
            end
        end
    end
    []
end

function max_flow(G, E, C, source, sink)
    F = zeros(C)
    #find augmenting path
    path = find_aug_path(G, F, C, source, sink)
    while length(path) > 0
        f = typemax(Int)
        draw_network(G,E,F)
        for i in 1:length(path)-1
            u, v = path[i], path[i+1]
            f = min(f, C[u, v] - F[u, v])
        end
        for i in 1:length(path)-1
            u, v = path[i], path[i+1]
            F[u, v] += f
        end
        path = find_aug_path()
    end
    F
end

function find_min_cut(G, E, C, F, source, sink)
    groups = ones(Int, nv(G))
    Q = Queue(Int)
    enqueue!(Q, 1)
    while length(Q) > 0
        n = dequeue!(Q)
        groups[n] = 2
        for nb in out_neighbors(G, n)
            if F[n, nb] < C[n, nb]
                enqueue!(Q, nb)
            end
        end
    end
    groups
end

function draw_initial_network()
    draw_network(G, E, F)
end

println("Praksisrammeverk importert. Beep boop")