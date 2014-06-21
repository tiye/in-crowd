
messages = []

module.exports =

  findOne: (messageId) ->
    for message in messages
      if message.messageId is messageId
        return message

  save: (data) ->
    message = @findOne data.messageId
    if message?
      message.text = data.text
    else
      messages.push data

  getBy: (topicId) ->
    messages.filter (message) ->
      message.topicId is topicId

  get: ->
    messages

  reset: (data) ->
    messages = data