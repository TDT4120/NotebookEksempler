#= Test format is given as as list with 4 elements.
	1. Input list
	2. Element to be found
	3. Element index in list
	4. Number of look-ups neccessary. This a array defining the allowed range of look-ups.
=#
test_A = [[1 2 3 4 5 6 7 8 9 10], 5, 5, [1,1], "test_A"]
test_B = [[1 2 3 4 5 6 7 8 9 10], 11, 0, [3,4], "test_B"]
test_C = [[1 2 3 4 5 6 7 8 9 10], 2, 2, [2,3], "test_C"]

tests = [test_A, test_B, test_C]

function check_code(implemented_func)
	for test in tests
		(index, lookups) = implemented_func(test[1], test[2])
		if index != test[3]
			println("Found wrong index with input $(test[1]). Expected $(test[3]) but got $index")

		elseif !(test[4][1] <= lookups <= test[4][2])
			println("Used too many/few lookups. Expected number of lookups to be in the range [$(test[4][1]), $(test[4][2])], but got $lookups")
		else
			println("Passed test $(test[5])") 
		end
	end		
end

	
