
action = require '../action'
mixins = require '../util/mixins'

topics = require '../models/topics'
states = require '../models/states'

TopicItem = require './topic-item'

module.exports = React.createClass
  displayName: 'topics-view'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo topics, @_onChange

  _onChange: ->
    @setState
      topics: topics.get()
      reading: states.getReading()

  getInitialState: ->
    topics: topics.get()
    reading: states.getReading()

  render: ->

    topicItems = @state.topics.map (topic) =>
      TopicItem data: topic, key: topic.topicId

    $.div
      id: 'topics-view'
      className: 'app-sidebar column-strech'
      $.input
        id: 'topics-input'
        className: 'darken'
        ref: 'input'
        placeholder: 'Create topic and post with Enter'
        onChange: =>
          draft = @refs.input.getDOMNode().value.trimLeft()
          action.draft draft
        onKeyDown: (event) =>
          if event.keyCode is 13
            action.post()
            @refs.input.getDOMNode().value = ''
      $.div
        id: 'topic-list'
        className: 'flex-fill'
        topicItems