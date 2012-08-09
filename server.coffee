
handler = (req, res) -> res.end 'sockets'

app = (require 'http').createServer handler
io = (require 'socket.io').listen app
app.listen 8005

io.sockets.on 'connection', (s) ->
  console.log 'sockets'