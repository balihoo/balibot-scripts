# Description:
#   Utility commands surrounding progrss quest stats.
#
# Commands:
#   hubot pg - return the progress quest info

module.exports = (robot) ->
	robot.respond /(reports)$/i, (msg) ->
		q = {gid: "18261"}
		msg.http('https://marketer-dev.balihoo.local/doc/sandbox/emailcampaigns.php')
		.query(q)
		.get() (err, res, body) ->
			msg.send body


			
