
action = require '../action'
mixins = require '../util/mixins'

states = require '../models/states'
members = require '../models/members'

module.exports = React.createClass
  displayName: 'message-item'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo states, @_onChange
    @listenTo members, @_onChange

    input = @refs.input
    if input
      input.getDOMNode().focus()

  getInitialState: ->
    saying: states.getSaying()

  _onChange: ->
    @setState @getInitialState()

  render: ->

    isSaying = @props.data.messageId is @state.saying
    member = members.findBy @props.data.userId
    username = member.name.trim()
    if username.length is 0
      username = '/anonym/'

    $$.if isSaying,
      =>
        $.div
          className: 'message-item message-saying row-start darken'
          $.input
            className: 'message-username'
            onChange: =>
            value: name
          $.input
            ref: 'input'
            className: 'message-text flex-fill'
            onChange: (event) =>
              say = event.target.value
              action.say say
            onKeyDown: (event) =>
              if event.keyCode is 13
                action.finish()
                @refs.input.getDOMNode().blur()
      =>
        $.div
          className: 'message-item row-start darken'
          $.span
            className: 'message-username'
            @props.data.username
          $.span
            className: 'message-text flex-fill'
            @props.data.text
