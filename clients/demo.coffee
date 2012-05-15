
window.onload = ->
  window.socket = io.connect '127.0.0.1:8000/chat'

  a = 'ready logout register login err topics topic-add topic-inc'
  a+= ' topic-enter post-open post-close post-end post-sync'
  for item in a.split(' ')
    do -> socket.on item, (j) -> console.log j

  socket.emit 'login', {username: 'nodejs', passwd: 'nodepass'}