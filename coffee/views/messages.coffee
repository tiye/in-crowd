
store = require '../store'
action = require '../action'
mixins = require '../util/mixins'

module.exports = React.createClass
  displayName: 'messages-view'

  mixins: [mixins.listenTo]

  componentDidMount: ->
    @listenTo store, @_onChange

  getIntialState: ->
    messages: store.getMessage()
    say: ''

  _onChange: ->
    @setState
      topics: store.getTopics()
      say: @state.say

  render: ->
    $.div
      id: 'messages-view'
      className: 'app-body flex-fill'
      'messages'