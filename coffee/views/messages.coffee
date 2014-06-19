
action = require '../action'
mixins = require '../util/mixins'

messages = require '../models/messages'
states = require '../models/states'

MessageItem = React.createClass
  displayName: 'message-item'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo states, @_onChange
    input = @refs.input
    if input
      input.getDOMNode().focus()

  getInitialState: ->
    saying: states.getSaying()

  _onChange: ->
    @setState @getInitialState()

  render: ->

    isSaying = @props.data.messageId is @state.saying

    $$.if isSaying,
      =>
        $.div
          className: 'message-item message-saying row-start'
          $.input
            className: 'message-username'
            onChange: =>
            value: @props.data.username
          $.input
            ref: 'input'
            className: 'message-text flex-fill'
            value: @props.data.text
            onChange: (event) =>
              say = event.target.value
              action.say say
            onKeyDown: (event) =>
              if event.keyCode is 13
                action.finish()
                @refs.input.getDOMNode().blur()
      =>
        $.div
          className: 'message-item row-start'
          $.span
            className: 'message-username'
            @props.data.username
          $.span
            className: 'message-text flex-fill'
            @props.data.text

module.exports = React.createClass
  displayName: 'messages-view'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo messages, @_onChange
    @listenTo states, @_onChange

  getInitialState: ->
    messages: messages.getBy states.getReading()
    say: ''
    reading: states.getReading()

  _onChange: ->
    @setState
      messages: messages.getBy states.getReading()
      say: messages.getSay()
      reading: states.getReading()

  render: ->

    if @state.reading?
      messageItems = @state.messages.map (message) =>
        MessageItem data: message, key: message.messageId
    else
      messageItems = []

    $.div
      id: 'messages-view'
      className: 'app-body flex-fill'
      messageItems

body = document.body
body.addEventListener 'keydown', (event) =>
  if event.target is body
    if event.keyCode is 13
      if states.getReading()?
        action.say ''