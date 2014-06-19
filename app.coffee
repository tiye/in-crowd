
uuid = require 'node-uuid'
server = require('ws-json-server')

User = require './src/user'
topics = require './src/topics'

port = 5031

store =
  topics: []
  messages: []

console.log 'listening', port
server.listen port, (ws) ->
  user = new User
  console.log user

  ws.on 'draft', (draft, res) ->
    draft = draft.trimLeft()
    user.updateDraft draft
    topic = user.getTopic()
    topics.save topic
    res topic

  ws.on 'post', (draft, res) ->
    draft = draft.trimLeft()
    topic = user.getTopic()
    res topic
    user.post()

  ws.on 'name', (name, res) ->
