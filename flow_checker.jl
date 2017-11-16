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

  function get_tests()
    #TODO: This should read from file
    input = []
    output= []

    test_folder = "tests/augpath/"
    test_files = ["1.txt", "2.txt", "3.txt", "4.txt", "5.txt", "6.txt", "7.txt", "8.txt"] 

    toIntList = x -> map(y -> parse(Int64, y), x)
    for file in test_files

        lines = []
        open(test_folder * file) do f
            lines = readlines(f)
        end

        numV, numE = toIntList(split(lines[1]))

        so, si = toIntList(split(lines[2]))

        G = DiGraph(numV)
        C = zeros(Int, numV, numV)
        F = zeros(C)
        E = []

        for i = 3:numE+2
            u, v, f, c = toIntList(split(lines[i]))
            push!(E, (u, v, f))
            add_edge!(G, u, v)
            C[u, v] = c
            F[u, v] = f
            F[v, u] = -f
        end

        push!(input, (G, E, F, C, so, si))

        numAnswers = parse(Int64, lines[numE+3])
        answers = []

        for i = numE+4:numE+4+numAnswers-1
            ans = toIntList(split(lines[i]))
            push!(answers, ans)
        end

        push!(output, AnyAnswer(Set(answers)))
        
    end

    return input, output

    #G = DiGraph(6)
    #E = [
    #    (1, 2, 16),
    #    (1, 3, 13),
    #    (3, 2, 4),
    #    (2, 4, 12),
    #    (4, 3, 9),
    #    (3, 5, 14),
    #    (4, 6, 20),
    #    (5, 4, 7),
    #    (5, 6, 4)
    #]

    #sort!(E)

    #C = zeros(Int, nv(G), nv(G))

    #for e in E
    #    u, v, c = e
    #    add_edge!(G, u, v)
    #    C[u, v] = c
    #end
    #F = zeros(C)
    #return (G, E, F, C, 1, 6)
  end
  test_input, test_expected_output = get_tests()

  #test_input = [get_input()]

  #test_expected_output = [
  #    AnyAnswer(Set(([1, 2, 4, 6],
  #                   [1, 3, 5, 6]
  #                  )))
  #]

end
