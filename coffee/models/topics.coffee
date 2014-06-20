
Dispatcher = require '../util/dispatcher'
ws = require '../util/ws'

store =
  topics: []
  draft: ''

module.exports = model = new Dispatcher

model.findOne = (topicId) ->
  for topic in store.topics
    if topic.topicId is topicId
      return topic

model.save = (data) ->
  topic = @findOne data.topicId
  if topic?
    topic.text = data.text
  else
    store.topics.unshift data
  @emit()

model.get = ->
  store.topics

ws.onload ->
  ws.on 'post', (topic) ->
    model.save topic

  ws.on 'draft', (topic) ->
    model.save topic

  ws.on 'topics', (topics) ->
    store.topics = topics
    model.emit()