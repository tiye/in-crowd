
fs = require 'fs'

uuid = require 'node-uuid'
server = require('ws-json-server')

User = require './src/user'
topics = require './src/topics'
messages = require './src/messages'
members = require './src/members'

port = 5031

dataFile = 'data/local.json'

save = ->
  local =
    messages: messages.get()
    topics: topics.get()
    members: members.get()
  raw = JSON.stringify local, null, 2
  fs.writeFileSync dataFile, raw

setInterval save, (1000 * 10)

if fs.existsSync dataFile
  raw = fs.readFileSync dataFile
  local = JSON.parse raw
  if local.messages? then messages.reset local.messages
  if local.topics? then topics.reset local.topics
  if local.members? then members.reset local.members

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

  ws.on 'topics', (_, res) ->
    res topics.get()

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

  ws.on 'user', (data, res) ->
    console.log 'client sent user:', data
    if data?
      console.log 'all members:', members.get()
      member = members.findBy data.userId, data.secret
    if member?
      console.log 'found user:', member
      user.updateId member
    else
      member = user.getMember()
      console.log 'add new user:', member
      members.save member
    res member

  ws.on 'members', (_, res) ->
    res members.get()

  ws.on 'name', (name, res) ->
    user.updateName name
    member = user.getMember()
    members.updateMember member
    ws.emit 'memberUpdate', member
    ws.broadcast 'memberUpdate', member

  ws.bind 'memberUpdate', (member) ->
    ws.emit 'memberUpdate', member