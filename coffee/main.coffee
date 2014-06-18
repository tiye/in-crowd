
require('./extend')

store = require './store'

MembersView = require('./views/members')
MesssagesView = require('./views/messages')

AppView = React.createClass
  displayName: 'app-view'

  render: ->
    $.div
      id: 'app-view'
      className: 'row-strech'
      MembersView({})
      MesssagesView({})

React.renderComponent AppView({}), document.body

body = document.body
body.addEventListener 'keydown', (event) =>
  if event.target is body
    if event.keyCode is 13
      store.startMessage()
