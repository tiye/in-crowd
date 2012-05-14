
ll = console.log
fs = require 'fs'

app = (require 'http').createServer (req, res) ->
  res.end 'world?'

io = (require 'socket.io').listen app, {origins: '*:*'}
io.set 'log level', 1
# io.set "transports", ["xhr-polling"]
# io.set "polling duration", 10
app.listen 8000

stemp = -> (String (new Date().getTime()))[-10..]

wait = 10

url = 'mongodb://nodejs:nodepass@localhost:27017/zhongli'
(require 'mongodb').connect url, (err, db) ->
  throw err if err?
  chat = (io.of '/chat').on 'connection', (socket) ->

    me =
      room: 'topics'
      address: socket.handshake.address.address
      authed: false
      name: undefined
      last_time: stemp()

    timing = ->
      old_time = me.last_time
      me.last_time = stemp()
      if me.last_time - old_time > wait then true else false

    join = (room) ->
      socket.leave me.room
      me.room = room
      socket.join me.room

    socket.emit 'ready', "got your ip #{me.address}", stemp()

    socket.on 'home', ->
      if timing()
        db.collection 'topics', (err, coll) ->
          (coll.find {}, {_id:0, ip:0}).toArray (err, topics) ->
            socket.emit 'topics', topics

    socket.on 'join', (room) ->
      if (typeof room is 'string') and timing()
        join room
        db.collection 'posts', (err, coll) ->
          (coll.find {}, {_id:0, ip:0}).toArray (err, posts) ->
            socket.emit 'posts', posts
      else socket.emit 'err', 'msg <join> wants string'

    socket.on 'open-chat', ->

    socket.on 'sync-chat', (words) ->

    socket.on 'save-chat', (words) ->
      if me.authed and timing()
        db.collection 'posts', (err, coll) ->
          ll 'save post'