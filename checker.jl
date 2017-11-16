module TheoryChecker
  export check_answers, IntOrFloatOrString

  # TODO: Should probably have a better name
  IntOrFloatOrString = Union{Int,AbstractFloat,AbstractString}

  # The struct used to collect data about a question/answer
  type AnswerMetadata
      datatype::DataType
      rangeCheck::Function
      correctAnswer::Nullable{IntOrFloatOrString}
  end
  # Constructor overload, we don't always need the correctAnswer field
  AnswerMetadata(datatype::DataType, rangeCheck::Function) = AnswerMetadata(datatype, rangeCheck, nothing)


  function rangeCheck(answer::String, allowed_answers::Array{String, 1})
      return answer in allowed_answers
  end
  function rangeCheck(answer::Int, allowed_answers::Array{Int, 1})
      return answer in allowed_answers
  end
  function rangeCheck(answer::Int, lowerBound::Int, upperBound::Int)
      return lowerBound <= answer && answer <= upperBound
  end
  function rangeCheck(answer::Float64, allowed_answers::Array{Float64, 1})
      return answer in allowed_answers
  end

  function check_error(is_error::Bool, error_msg::String)
    if is_error
        print_with_color(:red, "Test failed: $(error_msg)\n")
    end
    is_error
  end

  function check_answers(theory_answers::Dict{Int, IntOrFloatOrString}, expected_metadata::Dict{Int, AnswerMetadata})
      numCorrectAnswers::Int = 0
      numAnswers::Int = size(collect(keys(expected_metadata)))[1]
      is_error::Bool = false
      missing_answers::Set = setdiff(Set(collect(keys(expected_metadata))), Set(collect(keys(theory_answers))))
      is_error = is_error ||
                 check_error(!isempty(missing_answers),
                  "Question answers are missing for the following questions: $(missing_answers)")
      for k in keys(expected_metadata)
          is_error = is_error ||
              check_error(!isa(theory_answers[k], expected_metadata[k].datatype),
                  "Incompatible types for question $(k): Expected $(expected_metadata[k].datatype), got $(typeof(theory_answers[k]))")

          is_error = is_error ||
               check_error(!expected_metadata[k].rangeCheck(theory_answers[k]),
                   "Invalid answer provided for answer $(k) (out of range)")
          if expected_metadata[k].correctAnswer == theory_answers[k]
            numCorrectAnswers+=1
          end
      end
      @assert !is_error "Errors found"
      if !is_error
        print_with_color(:green, "All answers OK.\n")
      end
      numCorrectAnswers/numAnswers
  end

end

module CodeChecker
   export check_answers

   type AnyAnswer
     answers::Set
   end

   function check_answer(func::Function, input::Any, expectedOutput::Any, debug_function::Union{Function, Void} = nothing)
     output::Any = func(input...)
     if !in(output, expectedOutput.answers)
       print_with_color(:red, "Failed testcase")
       if debug_function != nothing
         debug_func(input...)
       else
         print("Input:\n$(input)\n\nExpected output:\n$(expectedOutput)\n\nOutput:\n$(output)\n")
       end
       return 0
     end
     return 1
   end


   function check_answers(func::Function, inputs::Any, expectedOutputs::Any, debug_function::Union{Function, Void} = nothing)
     #TODO: Fix type of inputs and outputs (Array of ..)
     @assert size(inputs) == size(expectedOutputs) "Different number of inputs and outputs"
     numTests::Int = size(inputs)[1]
     correct::Int = 0
     for i in 1:numTests
       correct += check_answer(func, inputs[i], expectedOutputs[i])
     end
     if correct == numTests
       print_with_color(:green, "All tests passed")
     else
       print_with_color(:red, "Failed $(numTests-correct) out of $(numTests) test(s).")
     end
     return correct/numTests
   end
end
