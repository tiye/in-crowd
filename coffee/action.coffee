
ws = require './util/ws'

topics = require './models/topics'
messages = require './models/messages'
members = require './models/members'
states = require './models/states'

exports.draft = (draft) ->
  ws.emit 'draft', draft

exports.post = ->
  ws.emit 'post'

exports.read = (topicId) ->
  ws.emit 'read', topicId
  states.read topicId

exports.say = (say) ->
  ws.emit 'say', say

exports.finish = (say) ->
  ws.emit 'finish'
  states.unsetSaying()

exports.name = (name) ->
  ws.emit 'name', name, (data) ->
    console.log name