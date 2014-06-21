
members = []

exports.findBy = (userId, secret) ->
  console.log members
  for member in members
    if member.userId is userId
      if member.secret is secret
        return member

exports.get = ->
  members.map (member) ->
    name: member.name
    userId: member.userId

exports.save = (data) ->
  for member in members
    if member.userId is data.userId
      member.name = data.name
      return
  members.push data

exports.updateMember = (user) ->
  for member in members
    if member.userId is user.userId
      member.name = user.name
      break