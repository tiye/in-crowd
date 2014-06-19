
Dispatcher = require '../util/dispatcher'
ws = require '../util/ws'

store =
  messages: []
  say: ''

module.exports = model = new Dispatcher

model.findOne = (messageId) ->
  for message in store.messages
    if message.messageId is messageId
      return message

model.save = (data) ->
  message = @findOne data.messageId
  if message?
    message.text = data.text
  else
    store.messages.push data
  @emit()

model.getBy = (topicId) ->
  store.messages.filter (message) ->
    message.topicId is topicId

model.updateSay = (say) ->
  store.say = say

model.getSay = ->
  store.say


ws.onload ->
  ws.on 'read', (messages) ->
    store.messages = messages
    model.emit()

  ws.on 'say', (message) ->
    model.save message

  ws.on 'finish', (message) ->
    model.save message