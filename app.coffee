 
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
format2 = (num) ->
  if num < 10 then '0' + (String num)
  else (String num)
watch = ->
  now    = new Date()
  year   = format2 (now.getFullYear() - 2000)
  month  = format2 (now.getMonth() + 1)
  date   = format2 now.getDate()
  hour   = format2 now.getHours()
  minute = format2 now.getMinutes()
  "#{year} #{month}/#{date} #{hour}:#{minute}"

url = 'mongodb://nodejs:nodepass@localhost:27017/zhongli'
(require 'mongodb').connect url, (err, db) ->
  throw err if err?
  chat = io.of('/chat').on 'connection', (socket) ->

    reply = (msg, f) ->
      socket.on msg, (data...) ->
        socket.emit msg, (f.apply f, data)

    me =
      room: 'topics'
      address: socket.handshake.address.address
      authed: false
      username: undefined
      last_time: stemp()
      thread: undefined

    timing = ->
      wait = 10
      old_time = me.last_time
      me.last_time = stemp()
      if me.last_time - old_time > wait then true
      else
        socket.emit 'err', 'Too frequent request!'
        false

    do join = (room = 'topics') ->
      socket.leave me.room
      me.room = room
      socket.join me.room

    socket.emit 'ready', "got your ip #{me.address}", stemp()

    check_user = (j) ->
      if          me.authed   then 'already user'
      else unless j?          then 'where s data'
      else unless j.username? then 'where s name'
      else unless j.passwd?   then 'where s passwd' else
        j.username = j.username.trim()
        unless 1< j.username.length <20 then 'name length: 1 to 20'
        else unless 5< j.passwd.length <30 then 'passwd length: 5 to 30'
        else 'ok'

    reply 'register', (j) ->
      check = check_user j
      if check isnt 'ok' then check
      else if timing()
        db.collection 'users', (err, coll) ->
          coll.findOne {username: j.username}, (err, item) ->
            if item?
              socket.emit 'register', 'name used'
            else
              profile =
                username: j.username
                passwd: j.passwd
                ip: me.address
                start: watch()
              coll.save profile, (err, result) ->
                socket.emit 'register', 'ok'
              me.username = j.username
              me.authed = yes
        'mongo...'

    reply 'logout', ->
      if me.authed
        me.authed = off
        'ok'
      else 'not even login'

    reply 'login', (j) ->
      check = check_user j
      if check isnt 'ok' then check
      else if timing()
        db.collection 'users', (err, coll) ->
          coll.findOne {username: j.username}, (err, item) ->
            if not item? then 'not such name' else
              if item.passwd is j.passwd
                me.authed = yes
                me.username = j.username
                socket.emit 'login', 'ok'
              else socket.emit 'login', 'wrong passwd'
          'mongo...'