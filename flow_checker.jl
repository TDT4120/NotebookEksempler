module FlowChecker
  include("checker.jl")
  using TheoryChecker: rangeCheck, AnswerMetadata
  using CodeChecker: AnyAnswer
  using LightGraphs
  using DataStructures
  export answer_metadata, test_data

  # TODO: Does a cleaner/simpler method exists? Lots of boilerplate here..
  answer_metadata = Dict{Int, AnswerMetadata}(
      (k, v) for (k,v) in enumerate([
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 3)),
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 3)),
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 4)),
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 3)),
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 3))])
  )

  function get_input()
    #TODO: This should read from file
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
    return (G, E, F, C, 1, 6)
  end

  test_input = [get_input()]

  test_expected_output = [
      AnyAnswer(Set(([1, 2, 4, 6],
                     [1, 3, 5, 6]
                    )))
  ]

end
