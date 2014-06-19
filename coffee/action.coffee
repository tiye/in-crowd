
ws = require './util/ws'

topics = require './models/topics'
messages = require './models/messages'
members = require './models/members'
states = require './models/states'

exports.draft = (draft) ->
  topics.updateDraft draft
  ws.emit 'draft', draft

exports.post = ->
  topics.updateDraft ''
  ws.emit 'post'

exports.read = (topicId) ->
  ws.emit 'read', topicId
  states.read topicId

exports.say = (say) ->
  messages.updateSay say
  ws.emit 'say', say

exports.finish = (say) ->
  messages.updateSay ''
  ws.emit 'finish'
  states.unsetSaying()