
window.onload = ->
  window.socket = io.connect '127.0.0.1:8000/chat'

  socket.on 'ready', (j) -> console.log j
  socket.on 'logout', (j) -> console.log j
  socket.on 'register', (j) -> console.log j
  socket.on 'login', (j) -> console.log j

  socket.on 'err', (j) -> console.log j