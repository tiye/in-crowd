 
ll = console.log
fs = require 'fs'

app = (require 'http').createServer (req, res) ->
  res.end 'world?'

io = (require 'socket.io').listen app, {origins: '*:*'}
io.set 'log level', 1
# io.set "transports", ["xhr-polling"]
# io.set "polling duration", 10
app.listen 8000

mark = -> String (new Date().getTime())
format2 = (num) -> if num<10 then '0'+(String num) else (String num)
time = ->
  now    = new Date()
  month  = format2 (now.getMonth() + 1)
  date   = format2 now.getDate()
  hour   = format2 now.getHours()
  minute = format2 now.getMinutes()
  {
    date: "#{month}/#{date}"
    time: "#{hour}:#{minute}"
  }

url = 'mongodb://nodejs:nodepass@localhost:27017/zhongli'
(require 'mongodb').connect url, (err, db) ->
  throw err if err?
  db.collection 'posts', (err, posts) ->
    throw err if err?
    posts.ensureIndex {mark: 1}
    db.collection 'topics', (err, topics) ->
      topics.ensureIndex {topic:1, mark: 1}
      throw err if err?
      chat = io.of('/chat').on 'connection', (socket) ->
        room = undefined
        thread = undefined

        error_handler = (info) ->
          socket.emit 'has-error', {info: info}

        name = undefined
        socket.on 'set-name', (data) ->
          try
            if data.name.trim().length is 0 then error_handler 'too short'
            else if data.name.trim().length > 15 then error_handler 'too long'
            else name = data.name.trim()
          catch error
            error_handler error

        socket.on 'add-topic', (data) ->
          if name?
            try
              if data.text.length > 0
                now = time()
                item =
                  name: name
                  date: now.date
                  time: now.time
                  text: data.text
                  mark: mark()
                topics.insert item
                chat.emit 'add-topic', item
              else error_handler 'cant save empty text'
            catch error
              error_handler error
          else error_handler 'cant add topic as an anonyous'

        socket.on 'add-post', (data) ->
          if name?
            try
              if data.text.length > 60 then error_handler 'too long, failed' else
                now = time()
                item =
                  name: name
                  date: now.date
                  time: now.time
                  text: data.text
                  mark: thread
                  topic: room
                posts.insert item
                thread = undefined
                chat.in(room).emit 'add-post', item
            catch error
              error_handler error
          else error_handler 'cant post as an anonyous'

        socket.on 'topic-list', ->
          topics
            .find({hide: {$exists: no}}, {limit: 20, sort: {mark: -1}})
            .toArray (err, list) ->
              if err? then error_handler err
              else socket.emit 'topic-list', list

        socket.on 'leave-topic', ->
          try
            socket.leave room
            room = undefined
            thread = undefined
          catch error
            error_handler error
        
        socket.on 'post-list', (data) ->
          try
            room = data.mark
            socket.join room
            posts
              .find(
                {topic: data.mark, hide: {$exists: no}},
                {limit: 10, sort: {mark: -1}})
              .toArray (err, list) ->
                throw err if err?
                socket.emit 'post-list', list
          catch error
            error_handler error

        socket.on 'sync-post', (data) ->
          try
            if data.head + data.text.length > 60
              error_handler 'too long, be short'
            else if thread?
              data.mark = thread
              chat.in(room).emit 'sync-post', data
            else
              thread = mark()
              now = time()
              item =
                name: name
                date: now.date
                time: now.time
                text: data.text
                mark: thread
              chat.in(room).emit 'new-post', item
          catch error
            error_handler error
      
      log = io.of('/log').on 'connection', (socket) ->
        auth = no
        step = 86400000
        error_handler = (info) ->
          socket.emit 'has-error', {info: info}

        socket.on 'login-auth', (data) ->
          try
            if data.name is 'admin' and data.auth is 'passwd'
              auth = yes
              console.log 'auth'
            else error_handler 'failed to auth'
          catch error
            error_handler info

        socket.on 'topic-list', (data) ->
          try
            start = data.mark
            end = String ((Number data.mark) + step)
            topics
              .find({mark: {$gte: start, $lte: end}, hide: {$exists: no}})
              .toArray (err, list) ->
                socket.emit 'topic-list', list
          catch error
            error_handler error

        socket.on 'post-list', (data) ->
          try
            posts
              .find({topic: data.mark, hide: {$exists: no}})
              .toArray (err, list) ->
                socket.emit 'post-list', list
          catch error
            error_handler error

        socket.on 'rm-topic', (data) ->
          if auth
            log.emit 'rm-topic', data
            console.log 'update'
            topics.update({mark: data.mark}, {$set: {hide: 1}})
          else error_handler 'dont have auth'

        socket.on 'rm-post', (data) ->
          if auth
            log.emit 'rm-post', data
            posts.update(
                {topic: data.topic, mark: data.mark},
                {$set: {hide: 1}})
          else error_handler 'dont have auth'