
topics = require '../models/topics'
action = require '../action'
mixins = require '../util/mixins'

TopicItem = React.createClass
  displayName: 'topic-item'

  render: ->
    $.div
      className: 'topic-item'
      @props.data.text

module.exports = React.createClass
  displayName: 'topics-view'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo topics, @_onChange

  _onChange: ->
    @setState
      topics: topics.get()
      draft: topics.getDraft()

  getInitialState: ->
    topics: topics.get()
    draft: ''

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
        onChange: =>
          draft = @refs.input.getDOMNode().value.trimLeft()
          action.draft draft
        onKeyDown: (event) =>
          if event.keyCode is 13
            draft = @refs.input.getDOMNode().value.trimLeft()
            action.post draft

      topicItems