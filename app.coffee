
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
    room = 'topic_list'
    socket.join room
    ip = socket.handshake.address.address
    sync_id = undefined
    post_thread_id = undefined

    give_topic_list = ->
      db.collection 'topic', (err, coll) ->
        coll.find {}, {_id:0}, (err, cursor) ->
          topic_list = []
          cursor.each (err, topic_item) ->
            if topic_item? then topic_list.push topic_item
            else socket.emit 'topic_list', topic_list

    socket.on 'send_local_name', (name_str) ->
      user_name = name_str
      socket.emit 'save_name_locally', user_name
      do give_topic_list

    socket.on 'add_topic', (topic_title, time_stemp) ->
      topic_item =
        time:   time_stemp
        ip:     ip
        author: user_name
        text:   topic_title
        reply:  0
      db.collection 'topic', (err, coll) ->
        coll.save topic_item
      (io.sockets.in 'topic_list').emit 'new_topic', topic_item

    socket.on 'goto_topic', (topic_id) ->
      socket.leave room
      room = topic_id
      socket.join room
      db.collection 'post', (err, coll) ->
        coll.find {topic:topic_id}, {_id:0, topic:0}, (err, cursor) ->
          post_list = []
          cursor.each (err, post_item) ->
            if post_item? then post_list.push post_item
            else socket.emit 'post_list', post_list

    socket.on 'post_box_close', (post_text, time_stemp) ->
      post_item =
        time:   post_thread_id
        ip:     ip
        author: user_name
        text:   post_text
        topic: room
      db.collection 'post', (err, coll) ->
        coll.save post_item
      socket.emit 'refresh_post', post_item
      (socket.broadcast.to room).emit 'post_box_close', post_item
      find_id = room.match /^([^:]+):(.+)$/
      room_ip = find_id[1]
      room_time = find_id[2]
      db.collection 'topic', (err, coll) ->
        coll.update {ip:room_ip, time:room_time}, {$inc: {reply: 1}}
      (socket.broadcast.to 'topic_list').emit 'increase_reply', room

    socket.on 'post_box_open', (time_stemp) ->
      sync_id = ip + ':' + time_stemp
      post_thread_id = time_stemp
      post_item =
        time:   time_stemp
        ip:     ip
        author: user_name
        text:   ''
        topic: room
      (socket.broadcast.to room).emit 'new_post', post_item

    socket.on 'post_box_sync', (post_box_value) ->
      (socket.broadcast.to room).emit 'post_box_sync', sync_id, post_box_value

    socket.on 'home', ->
      do give_topic_list
      socket.leave room
      room = 'topic_list'
      socket.join room