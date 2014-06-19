
ws = require './util/ws'

topics = require './models/topics'
messages = require './models/messages'
members = require './models/members'
states = require './models/states'

exports.draft = (draft) ->
  topics.updateDraft draft
  ws.emit 'draft', draft, (topic) ->
    topics.save topic

exports.post = (draft) ->
  topics.updateDraft ''
  ws.emit 'post', draft, (topic) ->
    topics.save topic