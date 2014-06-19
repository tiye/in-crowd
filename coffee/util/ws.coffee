
onLoadCalls = []

require('ws-json-browser')
.connect 5031, (ws) ->

  exports.emit = (args...) ->
    ws.emit args...

  exports.on = (args...) ->
    ws.on args...

  for cb in onLoadCalls
    cb ws

exports.onload = (cb) ->
  onLoadCalls.push cb
