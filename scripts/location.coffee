# Description:
#   say where you are
#
# Commands:
#   hubot <user> is in south korea
#   hubot where is <user> - see what roles a user has
#
# Examples:
#   hubot kyle is in an airstream
#   hubot kyle is not in an airstream

module.exports = (robot) ->

  if process.env.HUBOT_AUTH_ADMIN?
    robot.logger.warning 'The HUBOT_AUTH_ADMIN environment variable is set not going to load location.coffee, you should delete it'
    return

  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  robot.respond /where is @?([\w .\-]+)\?*$/i, (msg) ->
    joiner = ', '
    name = msg.match[1].trim()

    if name is "you"
      msg.send "the internet"
    else if name is robot.name
      msg.send "https://www.youtube.com/watch?v=f99PcP0aFNE"
    else
      users = robot.brain.usersForFuzzyName(name)
      if users.length is 1
        user = users[0]
        if user.location?
          msg.send "#{name} is in #{user.location}."
        else
          msg.send "#{name} is somewhere, probably?? idk????"
      else if users.length > 1
        msg.send getAmbiguousUserText users
      else
        msg.send "#{name}? Never heard of 'em"

  robot.respond /@?([\w .\-_]+) is in (["'\w: \-_]+)[.!]*$/i, (msg) ->
    name    = msg.match[1].trim()
    newLocation = msg.match[2].trim()

    unless name in ['', 'who', 'what', 'where', 'when', 'why']
      unless newLocation.match(/^not\s+/i)
        users = robot.brain.usersForFuzzyName(name)
        if users.length is 1
          user = users[0]
          if newLocation == user.location
            msg.send "I know"
          else
            if name.toLowerCase() is robot.name.toLowerCase()
              msg.send "do not tell me where i am, human"
            else
              msg.send "Ok, #{name} is in #{newLocation}."
              user.location = newLocation
        else if users.length > 1
          msg.send getAmbiguousUserText users
        else
          msg.send "I don't know anything about #{name}."

  # robot.respond /@?([\w .\-_]+) is not (["'\w: \-_]+)[.!]*$/i, (msg) ->
  #   name    = msg.match[1].trim()
  #   newRole = msg.match[2].trim()

  #   unless name in ['', 'who', 'what', 'where', 'when', 'why']
  #     users = robot.brain.usersForFuzzyName(name)
  #     if users.length is 1
  #       user = users[0]
  #       user.roles = user.roles or [ ]

  #       if newRole not in user.roles
  #         msg.send "I know."
  #       else
  #         user.roles = (role for role in user.roles when role isnt newRole)
  #         msg.send "Ok, #{name} is no longer #{newRole}."
  #     else if users.length > 1
  #       msg.send getAmbiguousUserText users
  #     else
  #       msg.send "I don't know anything about #{name}."