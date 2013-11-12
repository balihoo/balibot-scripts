# Description:
#   Utility commands surrounding progrss quest stats.
#
# Commands:
#   hubot pg|pq|progressquest - return the progress quest info

roman = require("roman");

module.exports = (robot) ->
	robot.respond /(progress ?quest|pq|pg)$/i, (msg) ->
		q = {gid: "18261"}
		msg.http('http://progressquest.com/pemptus.php').query(q).get() (err, res, body) ->
			regex = ///
			<tr\sclass=bob>
			<td\salign=right>(\d+) 	
			<td>(.+?)				
			<td>(.+?)
			<td>(.+?)
			<td\salign=right>(\d+)
			<td>(.+?)
			<td>Act\s(.+?)
			<td>(.+?)
			<td>(.+?)
			<td>(.*?)
			<td><a\shref="guilds.php\?id=18261
			///g
			matches = body.match regex
			#have to redeclare this as non global as apparently you can't just se the global property
			#see http://stackoverflow.com/questions/3811890/javascript-regular-expression-fails-every-other-time-it-is-called
			regex2 = ///
			<tr\sclass=bob>
			<td\salign=right>(\d+)	#rank
			<td>(.+?)				#name
			<td>(.+?)				#race
			<td>(.+?)				#class
			<td\salign=right>(\d+)	#level
			<td>(.{3}?)\s+(\d+?)	#prime stat
			<td>Act\s(.+?)			#plot stage/act
			<td>(.+?)				#prized item
			<td>(.+?)\s([MDCXLVI]+?)	#specialty/level
			<td>(.*?)				#motto
			<td><a\shref="guilds.php\?id=18261
			///
			submatches = (regex2.exec(m)[1..] for m in matches)
			characters = submatches.map (sm) ->
				rank : sm[0]
				name : sm[1]
				race : sm[2]
				class : sm[3]
				level : sm[4]
				stat : sm[5]
				statval : sm[6]
				act : sm[7]
				item : sm[8]
				specialty : sm[9]
				specialtylevel : sm[10]
				motto : sm[11]
			

			#sort by stat
			characters.sort (a,b) ->
				b.statval - a.statval
			highstat = characters[0]

			#sort by specialty level
			characters.sort (a,b) ->
				roman.roman2decimal(b.specialtylevel) - roman.roman2decimal(a.specialtylevel)
			highskill = characters[0]

			#sort by rank for table
			characters.sort (a,b) ->
				a.rank - b.rank
			leader = characters[0]
			clan = "Balihoo Developers"
			message = "#{leader.name}, the leader of clan #{clan} shouts \"#{leader.motto}\" while waving his #{leader.item}"
			message += "\n"
			message += "#{highstat.name} has the highest stat of #{highstat.statval} for #{highstat.stat}"
			message += "\n"
			message += "#{highskill.name} has the highest leveled specialty, #{highskill.specialty} #{highskill.specialtylevel}"
			message += "\n"
			message += "Top 10 of clan #{clan} by level:"
			message += "\n"
			message += "#{c.rank} - #{c.name} the #{c.race} is at Level #{c.level}\n" for c in characters
			message += "reference: http://progressquest.com/pemptus.php?gid=18261"
			msg.send message


			
