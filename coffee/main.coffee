
require('./util/extend')
ws = require './util/ws'

AppView = require './views/app'

React.renderComponent AppView({}), document.body

dataKey = 'uesr-in-crowd'

user = {}
local = localStorage.getItem(dataKey)
if local?
  user = JSON.parse local

ws.onload ->
  console.log 'local user:', user
  ws.emit 'user', user, (data) ->
    user = data
    console.log 'identified as user:', data
    ws.emit 'members', [], (ret) ->
      console.log 'ret:', ret

window.onbeforeunload = ->
  localStorage.setItem dataKey, (JSON.stringify user)