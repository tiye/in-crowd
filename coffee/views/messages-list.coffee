
action = require '../action'
mixins = require '../util/mixins'

messages = require '../models/messages'
states = require '../models/states'

MessageItem = require './message-item'

module.exports = React.createClass
  displayName: 'messages-view'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo messages, @_onChange
    @listenTo states, @_onChange

  getInitialState: ->
    messages: messages.getBy states.getReading()
    reading: states.getReading()

  _onChange: ->
    @setState
      messages: messages.getBy states.getReading()
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