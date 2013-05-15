# Description:
#   Utility commands surrounding progrss quest stats.
#
# Commands:
#   hubot pg|pq|progressquest - return the progress quest info

permcomb = require "permcomb" #https://github.com/rayie/permcomb
sleep = require "sleep"

module.exports = (robot) ->
	robot.respond /(run puzzle )(with details )?(on )?(https?:\/\/.+)$/i, (msg) ->
		ServiceURL = msg.match[4]
		WithDetails = msg.match[2] is "with details "

		#Perform a ping to see that the service is there at least
		ping = {q: "Ping"}

		#Some implementations require this....unfortunately
		Service = msg.http(ServiceURL).header("User-Agent", "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.64 Safari/537.31")

		Service.query(ping).get() (err, res, body) ->
			#TODO: add error check

			if body is not "OK"
				msg.send "Non-OK response to ping at #{ServiceURL}: #{body}"
				return
			
			msg.send "Ping succeeded to #{ServiceURL}, attempting all puzzle permutations.  This may take a moment... (Include Details: #{WithDetails})"
			
			permcomb.permutate ["A","B","C","D"], 4, (err, Permutations)->
				#TODO: check for errors
				TotalPermutations = Permutations.length #should be 24

				Correct = []
				Incorrect = []
				Error = []

				#Making the requests async has caused problems in the past with certain implementations (usually a host problem)
				#So using a recursive callback technique to make the requests synchronously
				r = (permutation)->
					PuzzleData = MakePuzzle(permutation)
					query = {q : "Puzzle", d : "Solve:\n#{PuzzleData.Problem}" }

					Service.query(query).get() (err, res, body) ->
						#TODO: add error check

						PuzzleData.Answer = body
						if PuzzleData.Answer.trim() is PuzzleData.Solution.trim()
							Correct.push PuzzleData

							if WithDetails
								msg.send "A Correct Puzzle Answer was Received"
								SendPuzzleData msg, PuzzleData

						else
							Incorrect.push PuzzleData
							
							if WithDetails
								msg.send "An Incorrect Puzzle Answer was Received"
								SendPuzzleData msg, PuzzleData

						#We're done!
						if Permutations.length is 0
							if Correct.length is TotalPermutations
								msg.send "All permutations sent to #{ServiceURL} succeeded"
								return

							if Incorrect.length is 1
								msg.send "Only 1 Puzzle sent to #{ServiceURL} was Answered Incorrect"
								SendPuzzleData msg, Incorrect[0]
								return

							msg.send "#{ServiceURL} Got #{Correct.length} Correct & #{Incorrect.length} Incorrect.  Run with details to see problems"
							return

						#We're not done yet, call again
						r( Permutations.pop() )

				#Initialize the chain!
				r( Permutations.pop() )		

	

SendPuzzleData = (robot, PuzzleData) ->
	message = "The Order for this problem was #{PuzzleData.Order}\nSent\tWanted\tGot\n"
	
	ProblemLines = PuzzleData.Problem.split("\n")
	AnswerLines = PuzzleData.Answer.split("\n")
	SolutionLines = PuzzleData.Solution.split("\n")

	for i in [0...5]
		message += "#{ProblemLines[i]}\t#{SolutionLines[i]}\t#{AnswerLines[i]}\t\n"

	robot.send message

	

GetRelationship = (Collection, Item1, Item2) ->
	a = Collection.indexOf(Item1)
	b = Collection.indexOf(Item2)
	if a > b
		return ">"
	if a < b
		return "<"
	if a is b
		return "="

MakePuzzle = (OrderedLetters) ->
	Letters = ["A","B","C","D"]
	Solution = " " + Letters.join("")
	Problem = " " + Letters.join("")
	for rowLetter in Letters
		Solution += "\n" + rowLetter
		Problem += "\n" + rowLetter
		for colLetter in Letters
			
			Solution += GetRelationship(OrderedLetters, rowLetter, colLetter)

			#minimum  we only need put in 3 relationships between the 4 letters
			#here we add how the first relates to second, second to third, and thrid to fourth
			if (rowLetter == colLetter)
				Problem += "="
			else if (rowLetter == OrderedLetters[0] && colLetter == OrderedLetters[1])
				Problem += GetRelationship(OrderedLetters, rowLetter, colLetter)
			else if (rowLetter == OrderedLetters[1] && colLetter == OrderedLetters[2])
				Problem += GetRelationship(OrderedLetters, rowLetter, colLetter)
			else if (rowLetter == OrderedLetters[2] && colLetter == OrderedLetters[3])
				Problem += GetRelationship(OrderedLetters, rowLetter, colLetter)
			else
				Problem += "-"			
	return {"Order" : OrderedLetters.join(""),  "Problem" : Problem, "Solution" : Solution}


			


			
