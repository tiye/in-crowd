
action = require '../action'
mixins = require '../util/mixins'
format = require '../util/format'

states = require '../models/states'
members = require '../models/members'

module.exports = React.createClass
  displayName: 'topic-item'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo states, @_onChange
    @listenTo members, @_onChange

  getInitialState: ->
    reading: states.getReading()
    members: members.get()

  _onChange: ->
    @setState @getInitialState()

  render: ->

    isReading = @props.data.topicId is @state.reading
    username = members.findBy(@props.data.userId).name

    $.div
      className: $$.concat 'topic-item darken',
        if isReading then 'topic-reading'
      onClick: =>
        action.read @props.data.topicId
      $.div {},
        @props.data.text
      $$.if isReading, =>
        $.div {},
          @props.data.text
        $.div {},
          $.span
            className: 'topic-username'
            name
          $.span
            className: 'topic-time'
            format.today @props.data.time
