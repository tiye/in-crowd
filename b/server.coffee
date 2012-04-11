
require 'coffee-script'
g = (require './method.coffee').g

handler = (req, res) ->
  page = ''
  if req.url is '/' then page = do g.page
  res.writeHead 200, 'Content-Type': 'text/html'
  res.end page

app = (require 'http').createServer handler
app.listen 8000

io = (require 'socket.io').listen app
io.set 'log level', 1
io.sockets.on 'connection', (socket) ->
  socket.on 'login_key', (assertion) ->
    g.login assertion, (err, data) ->
      throw err if err?
      console.log data.email