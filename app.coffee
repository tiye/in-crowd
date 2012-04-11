
ll = console.log
fs = require 'fs'

app = (require 'http').createServer (req, res) ->
  page = fs.readFileSync 'page.html', 'utf-8'
  client = fs.readFileSync 'client.coffee', 'utf-8'
  page = page.replace '@@@', client

  res.writeHead 200, 'Content-Type': 'text/html'
  res.end page

io = (require 'socket.io').listen app
io.set 'log level', 1
# io.set "transports", ["xhr-polling"]
# io.set "polling duration", 10
app.listen 8000

url = 'mongodb://nodejs:nodepass@localhost:27017/zhongli'
(require 'mongodb').connect url, (err, db) ->
  io.sockets.on 'connection', (socket) ->
    socket.emit 'ready'
    user_name = undefined
    ip = socket.handshake.address.address

    send_topic_page = ->
      db.collection 'topic', (err, collection) ->
        collection.find {},
          {author:1, date:1, id:1, reply:1, text:1, _id:0},
          (err, cursor) ->
            topic_arr = []
            cursor.each (err, x) ->
              if x?
                topic_arr.push x
              else
                socket.emit 'topic_arr', topic_arr

    socket.on 'send_name', (set_name) ->
      user_name = set_name
      socket.emit 'save_name', user_name
      do send_topic_page