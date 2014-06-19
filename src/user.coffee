
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