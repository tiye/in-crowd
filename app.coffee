 
ll = console.log
fs = require 'fs'

app = (require 'http').createServer (req, res) ->
  res.end 'world?'

io = (require 'socket.io').listen app, {origins: '*:*'}
io.set 'log level', 1
# io.set "transports", ["xhr-polling"]
# io.set "polling duration", 10
app.listen 8000

mark = -> (String (new Date().getTime()))[-10..]
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
      topics.ensureIndex {mark: 1}
      throw err if err?
      chat = io.of('/chat').on 'connection', (socket) ->
        ll 'ok'
        # setInterval (->
        #   socket.emit 'has-error', {info: 'xxx'}
        #   ll 'xxx'), 2000
        error_handler = (info) ->
          socket.emit 'has-error', {info: info}

        name = undefined
        socket.on 'set-name', (data) ->
          ll data
          if data.name.trim().length is 0 then error_handler 'too short'
          else if data.name.trim().length > 15 then error_handler 'too long'
          else name = data.name.trim()
          ll 'name:', name

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
              error_handler (String error)
          else error_handler 'cant add topic as an anonyous'

        socket.on 'add-post', (data) ->
          if name?
            console.log data
          else error_handler 'cant post as an anonyous'

        socket.on 'topic-list', ->
          topics.find({}, {limit: 20, sort: {mark: -1}}).toArray (err, list) ->
            if err? then error_handler err
            else socket.emit 'topic-list', list