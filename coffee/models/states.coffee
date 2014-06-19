
Dispatcher = require '../util/dispatcher'
ws = require '../util/ws'

store =
  reading: undefined
  saying: undefined

module.exports = model = new Dispatcher

model.read = (topicId) ->
  store.reading = topicId
  @emit()

model.getReading = ->
  store.reading

model.say = (messageId) ->
  store.saying = messageId
  @emit()

model.getSaying = ->
  store.saying

model.unsetSaying = ->
  store.saying = undefined
  @emit()

ws.onload ->
  ws.on 'saying', (messageId) ->
    model.say messageId