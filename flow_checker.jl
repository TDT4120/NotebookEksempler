module FlowChecker
  include("checker.jl")
  using TheoryChecker: rangeCheck, AnswerMetadata
  export answer_metadata

  # TODO: Does a cleaner/simpler method exists? Lots of boilerplate here..
  answer_metadata = Dict{Int, AnswerMetadata}(
      (k, v) for (k,v) in enumerate([
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 3)),
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 3)),
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 4)),
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 3)),
          AnswerMetadata(Int, x::Int -> rangeCheck(x, 1, 3))])
  )
end
