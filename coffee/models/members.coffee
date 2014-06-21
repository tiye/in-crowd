
Dispatcher = require '../util/dispatcher'
ws = require '../util/ws'

store =
  members: []

module.exports = model = new Dispatcher

model.findBy = (userId) ->
  for member in store.members
    if member.userId is userId
      return member

model.get = ->
  store.members

model.save = (data) ->
  for member in store.members
    if member.userId is data.userId
      member.name = member.name
      return
  store.members.push data
  @emit()

model.reset = (data) ->
  store.members = data
  @emit()

model.update = (data) ->
  member = @findBy data.userId
  member.name = data.name
  @emit()

ws.onload ->
  ws.on 'members', (data) ->
    console.log 'got member list:', data
    model.reset data
    ws.emit 'topics'

  ws.on 'memberUpdate', (member) ->
    model.update member