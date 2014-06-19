
action = require '../action'
mixins = require '../util/mixins'

topics = require '../models/topics'
states = require '../models/states'

TopicItem = React.createClass
  displayName: 'topic-item'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo states, @_onChange

  getInitialState: ->
    reading: states.getReading()

  _onChange: ->
    @setState @getInitialState()

  render: ->

    isReading = @props.data.topicId is @state.reading

    $.div
      className: $$.concat 'topic-item',
        if isReading then 'topic-reading'
      onClick: =>
        action.read @props.data.topicId
      $.div {},
        @props.data.text
      $$.if isReading, =>
        $.div {},
          @props.data.text
        $.div {},
          $.span {},
            @props.data.username
          $.span {},
            @props.data.time

module.exports = React.createClass
  displayName: 'topics-view'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo topics, @_onChange

  _onChange: ->
    @setState
      topics: topics.get()
      draft: topics.getDraft()
      reading: states.getReading()

  getInitialState: ->
    topics: topics.get()
    draft: ''
    reading: states.getReading()

  render: ->

    topicItems = @state.topics.map (topic) =>
      TopicItem data: topic, key: topic.topicId

    $.div
      id: 'topics-view'
      className: 'app-sidebar column-strech'
      $.input
        id: 'topics-input'
        value: @state.draft
        ref: 'input'
        placeholder: 'Create topic and post with Enter'
        onChange: =>
          draft = @refs.input.getDOMNode().value.trimLeft()
          action.draft draft
        onKeyDown: (event) =>
          if event.keyCode is 13
            action.post()

      topicItems