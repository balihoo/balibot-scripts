# Description:
#   Sends SVN commits to chat
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# URLS:
#   /hubot/svn

#  SVN hook example:
#  revision=$2 
#  log=$(svnlook log /opt/svn/repo -r $revision) 
#  author=$(svnlook author /opt/svn/repo -r $revision) 
#  curl damour.balihoo.local:5555/hubot/svn -f -m 10 --data "repo=sandbox" --data "revision=$revision" --data "log=$log" --data "username=$author" 

# Basic structure taken from http://blog.codiform.com/2012/05/getting-hubot-to-chat-commits-to.html

# TODO: switch to an event emit so that scripts like SVN commit, crucible, and jira can output
module.exports = (robot) ->
	
  robot.router.post "/hubot/svn", (req, res) ->
    repo = req.body.repo
    message = req.body.log
    revision = req.body.revision
    username = req.body.username
    
    #room is hacked until i figure out how to query for it
    robot.send { room:"34840" }, "#{repo} #{revision} #{username} #{message}"

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end "Thanks; subversion commit written to chat.\n"


