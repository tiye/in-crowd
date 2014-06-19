
require('./util/extend')

store = require './store'
ws = require './util/ws'

AppView = require './views/app'

ws.onload = ->
  console.log 'connected'

React.renderComponent AppView({}), document.body

body = document.body
body.addEventListener 'keydown', (event) =>
  if event.target is body
    if event.keyCode is 13
      store.startMessage()
      alert 'ok'