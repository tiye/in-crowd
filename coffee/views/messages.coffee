
action = require '../action'
mixins = require '../util/mixins'

messages = require '../models/messages'
states = require '../models/states'

MessageItem = React.createClass
  displayName: 'message-item'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo states, @_onChange

  getInitialState: ->
    saying: states.getSaying()

  _onChange: ->
    @setState @getInitialState()

  render: ->

    isSaying = @props.data.messageId is @state.saying

    $$.if isSaying,
      =>
        $.div
          className: 'message-item message-saying'
          $.input
            className: 'username'
            value: @props.data.username
          $.input
            className: 'message-text'
            value: @props.data.text
      =>
        $.div
          className: 'message-item'
          $.span
            className: 'username'
            @props.data.username
          $.span
            className: 'message-text'
            value: @props.data.text

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

    console.log 'state:', @state

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