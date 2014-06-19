
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
      messages.unshift data

  getBy: (topicId) ->
    messages.filter (message) ->
      message.topicId is topicId