
uuid = require 'node-uuid'
server = require('ws-json-server')

User = require './src/user'
topics = require './src/topics'
messages = require './src/messages'

port = 5031

store =
  topics: []
  messages: []

console.log 'listening', port
server.listen port, (ws) ->
  user = new User

  ws.on 'draft', (draft, res) ->
    user.updateDraft draft
    topic = user.getTopic()
    topics.save topic
    res topic
    ws.broadcast 'draft', topic

  ws.on 'post', (_, res) ->
    topic = user.getTopic()
    res topic
    user.post()

  ws.on 'read', (topicId, res) ->
    user.read topicId
    res (messages.getBy topicId)

  ws.emit 'topics', topics.get()

  ws.on 'say', (say, res) ->
    user.updateSay say
    message = user.getMessage()
    messages.save message
    ws.emit 'saying', message.messageId
    res message
    ws.broadcast 'say', message

  ws.on 'finish', (_, res) ->
    message = user.getMessage()
    res message
    user.finish()

  ws.bind 'draft', (data) ->
    ws.emit 'draft', data

  ws.bind 'say', (data) ->
    ws.emit 'say', data

  ws.on 'name', (name, res) ->
