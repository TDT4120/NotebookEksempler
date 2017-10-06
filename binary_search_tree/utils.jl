module Utils
    using Luxor
    using Interact
    using Reactive

    export Node, Tree, draw, highlight, visualize_tree_algorithm, example_tree, height, count_nodes, has_cycles

    mutable struct Node
        key::Int
        left::Union{Void, Node}
        right::Union{Void, Node}
        p::Union{Void, Node}
        Node(key::Int) = new(key, nothing, nothing, nothing)
    end
    mutable struct ObservableNode
        key::Int
        left::Union{Void, ObservableNode}
        right::Union{Void, ObservableNode}
        p::Union{Void, ObservableNode}
        ObservableNode(key::Int) = new(key, nothing, nothing, nothing)
    end

    mutable struct Tree
        root::Union{Void, Node}
        Tree() = new(nothing)
        Tree(n::Node) = new(n)
    end
    mutable struct ObservableTree
        root::Union{Void, ObservableNode}
        ObservableTree() = new(nothing)
        ObservableTree(n::ObservableNode) = new(n)
    end

    observable(nothing, _) = nothing
    function observable(T::Tree)
        ObservableTree(observable(T.root, nothing))
    end
    function observable(x::Node, p::Union{Void,ObservableNode})
        o = ObservableNode(x.key)
        o.left = observable(x.left, o)
        o.right = observable(x.right, o)
        o.p = p
        o
    end

    unobservable(nothing, _) = nothing
    function unobservable(T::ObservableTree)
        ObservableTree(unobservable(T.root, nothing))
    end
    function unobservable(x::ObservableNode, p::Union{Void,Node})
        o = Node(x.key)
        o.left = unobservable(x.left, o)
        o.right = unobservable(x.right, o)
        o.p = p
        o
    end

    function _tree_insert!(T::Tree, z::Node)
        y = nothing
        x = T.root
        while x != nothing
            y = x
            if z.key < x.key
                x = x.left
            else
                x = x.right
            end
        end
        z.p = y
        if y == nothing
            T.root = z # tree T was empty
        elseif z.key < y.key
            y.left = z
        else
            y.right = z
        end
        T
    end

    function has_cycles(x::T) where {T}
        visited = Array{T, 1}()
        stack = Array{Union{Void, T}, 1}()
        push!(stack, x)
        while !isempty(stack)
            n = pop!(stack)
            if n != nothing
                if n in visited
                    return true
                end
                push!(visited, n)
                push!(stack, n.left)
                push!(stack, n.right)
            end
        end
        return false
    end

    function height(x)
        h = 0
        if x.left != nothing
            h = max(h, 1 + height(x.left))
        end
        if x.right != nothing
            h = max(h, 1 + height(x.right))
        end
        return h
    end

    function count_nodes(x)
        if x == nothing
            return 0
        else
            return 1 + count_nodes(x.left) + count_nodes(x.right)
        end
    end


    const NODE_RADIUS = 12
    function _draw(x, layer_height::Real, width::Real, select)
        if x.left != nothing
            setcolor("black")
            line(Point(0, 0), Point(-width/4, layer_height), :stroke)
            gsave()
            translate(-width/4, layer_height)
            _draw(x.left, layer_height, width/2, select)
            grestore()
        end
        if x.right != nothing
            setcolor("black")
            line(Point(0, 0), Point(width/4, layer_height), :stroke)
            gsave()
            translate(width/4, layer_height)
            _draw(x.right, layer_height, width/2, select)
            grestore()
        end

        setcolor(get(select, x, "white"))
        circle(0, 0, NODE_RADIUS, :fill)
        setcolor("black")
        fontsize(10)
        circle(0, 0, NODE_RADIUS-1, :stroke)
        x_bearing, y_bearing, width, height, x_advance, y_advance = textextents(repr(x.key))
        pt = Point(-width/2, -y_bearing-height/2)
        text(repr(x.key), pt, halign=:left, valign=:bottom)

    end

    function draw(x, select::Dict=Dict())
        if has_cycles(x)
            throw("The tree has cycles!")
        end

        W = min(600, 2.5 * NODE_RADIUS * 2^height(x))
        H = NODE_RADIUS*2 + height(x) * 50
        Drawing(W, H, "tree.svg")
        origin()
        translate(0, -H/2 + NODE_RADIUS)

        _draw(x, (H - NODE_RADIUS * 2) / height(x), W - NODE_RADIUS*2, select)
        finish()
        display("text/html", "<img src=\"tree.svg?$(rand(0:10^10))\" />")
    end

    example_tree() = begin
        T = Tree();
        _tree_insert!(T, Node(6))
        _tree_insert!(T, Node(3))
        _tree_insert!(T, Node(7))
        _tree_insert!(T, Node(4))
        _tree_insert!(T, Node(5))
        _tree_insert!(T, Node(1))
        _tree_insert!(T, Node(2))
        _tree_insert!(T, Node(10))
        _tree_insert!(T, Node(9))
        _tree_insert!(T, Node(11))
    end


    nextstep_cond = Condition()
    mutable struct GlobalTask
        task::Union{Void, Task}
        i::Int
        T::ObservableTree
        button_next
    end
    current_task = GlobalTask(nothing, 1, ObservableTree(), button("Next"))
    foldp((acc, value) -> notify(nextstep_cond), 0, signal(current_task.button_next))

    function highlight_nodes(select)
        display(current_task.button_next)
        draw(current_task.T.root, select)
        println("Step number ", current_task.i)
        current_task.i += 1
        wait(nextstep_cond)
        IJulia.clear_output()
    end


    function highlight(x::Node, color="yellow")
    end

    function highlight(nothing, color="yellow")
    end

    function highlight(x::ObservableNode, color="yellow")
        highlight_nodes(Dict(x=>color))
    end

    function visualize_tree_algorithm(func, T::Tree)
        if current_task.task != nothing
            Base.notify_error(nextstep_cond, InterruptException())
            current_task.task = nothing
        end
        current_task.i = 1
        current_task.T = observable(T)
        foldp((acc, value) -> notify(nextstep_cond), 0, signal(current_task.button_next))
        current_task.task = @async begin
            try
                func(current_task.T)
                T.root = unobservable(current_task.T.root, nothing)
            catch e
                if !isa(e, InterruptException)
                    rethrow(e)
                end
            end
        end
        nothing
    end
end

nothing