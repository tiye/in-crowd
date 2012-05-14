
window.onload = ->
  window.socket = io.connect '127.0.0.1:8000/chat'
  socket.on 'ready', (data...) ->
    console.log data

  socket.on 'err', (msg) -> console.log 'ERROR:', msg

  socket.on 'posts', (data) -> console.log 'Posts:', data
  socket.on 'topics', (data) -> console.log 'Topics:', data
