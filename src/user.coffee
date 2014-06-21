
uuid = require 'node-uuid'

module.exports = class User
  constructor: ->
    @id = uuid.v1()
    @secret = uuid.v1()
    @name = ''
    @reading = undefined

    @drafting = undefined
    @draft = ''
    @draftTime = undefined

    @saying = undefined
    @say = ''

  updateDraft: (draft) ->
    draft = draft.trimLeft()
    @draft = draft
    unless @drafting?
      @drafting = uuid.v1()
      @draftTime = (new Date).toISOString()

  getTopic: ->
    topicId: @drafting
    text: @draft
    time: @draftTime
    userId: @id
    username: @name

  post: ->
    @drafting = undefined
    @draft = ''

  read: (topicId) ->
    @reading = topicId

  updateSay: (say) ->
    say = say.trimLeft()
    @say = say
    unless @saying?
      @saying = uuid.v1()
      @sayTime = (new Date).toISOString()

  getMessage: ->
    messageId: @saying
    text: @say
    time: @sayTime
    userId: @id
    topicId: @reading

  finish: ->
    @saying = undefined
    @say = ''

  getMember: ->
    name: @name
    userId: @id
    secret: @secret

  updateId: (data) ->
    @id = data.userId
    @secret = data.secret
    console.log 'updateId:', data
