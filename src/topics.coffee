
topics = []

module.exports =

  findOne: (topicId) ->
    for topic in topics
      if topic.topicId is topicId
        return topic

  save: (data) ->
    topic = @findOne data.topicId
    if topic?
      topic.text = data.text
    else
      topics.unshift data
