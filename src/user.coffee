
uuid = require 'node-uuid'

module.exports = class User
  constructor: ->
    @id = uuid.v1()
    @name = 'Anonym'
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
    username: @name
    topicId: @reading

  finish: ->
    @saying = undefined
    @say = ''
