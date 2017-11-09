using DataFrames

#=
 results_file: CSV file containing two columns, Brukernavn and Poeng. 
 data_file: CSV file containing five columns, _Etternavn, Fornavn, Brukernavn, Student_ID and Poeng
 out_file: Result file
=#

if length(ARGS) == 2
	data_file = ARGS[1]
	results_file = ARGS[2]
else
	data_file = "grades.csv"
	results_file = "points.csv"
end

out_file = "grades_with_points.csv"

# Loading files
data = readtable(data_file, nastrings=["#NULL"])
in_data = readtable(results_file, nastrings=["#NULL"])

# Determining sizes
nrows, ncols = size(data)
nrows_in, ncols_in = size(in_data)

# Initialize result array
results = Array{Float64}(nrows)

# Populate results array based on information in results_file and data_file
for row in 1:nrows
	bruker = data[row, :Brukernavn]
	points = 0.0
	for row_in in 1:nrows_in
		if in_data[row_in, :Brukernavn] == bruker
			points = in_data[row_in, :Poeng]

		end
	end

	results[row] = points
end

# Save results
data[end] = results
writetable(out_file, data)

