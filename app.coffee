 
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
        socket.emit msg, (f.apply f, data) or 'we are both robots'

    me =
      room: undefined
      address: socket.handshake.address.address
      authed: false
      username: undefined
      mark: undefined
      count: 0

    setInterval (-> me.count = 0), 1000
    limit = 20
    timing = ->
      if (me.count+=1) < limit then true else false

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

    reply 'register', (j) -> if timing()
      check = check_user j
      if check isnt 'ok' then check
      else
        db.collection 'users', (err, coll) ->
          coll.findOne {username: j.username}, (err, item) ->
            if item?
              socket.emit 'register', 'name used'
            else
              profile =
                username: j.username
                passwd: j.passwd
                ip: [me.address]
                time: watch()
              coll.save profile, (err, result) ->
                socket.emit 'register', 'ok'
              me.username = j.username
              me.authed = yes
        'mongo...'

    reply 'logout', -> if timing()
      if me.authed
        me.authed = off
        'ok'
      else 'not even login'

    reply 'login', (j) -> if timing()
      check = check_user j
      if check isnt 'ok' then check else
        db.collection 'users', (err, coll) ->
          coll.findOne {username: j.username}, (err, item) ->
            if not item? then socket.emit 'login', 'not such name'
            else
              if item.passwd is j.passwd
                me.authed = yes
                me.username = j.username
                if not (me.address in item.ip)
                  coll.update $push: {ip: me.address}
                socket.emit 'login', 'ok'
              else socket.emit 'login', 'wrong passwd'
        'mongo...'

    reply 'topics', -> if timing()
      if me.room is 'topics' then 'already here' else
        db.collection 'topics', (err, coll) ->
          coll.find({}, {_id:0}).toArray (err, list) ->
            socket.emit 'topics', list
        'mongo...'

    reply 'topic-add', (j) -> if timing()
      if not me.authed then 'anonymous topic dropped'
      else if not j? then 'where s data'
      else if not j.text then 'where s text'
      else if (typeof j.text) isnt 'string' then 'mark wants string'
      else if not (1< j.text.length <40) then 'text length 1 to 40' else
        profile =
          text: j.text
          time: watch()
          name: me.username
          mark: stemp()
          reply: 0
        db.collection 'topics', (err, coll) ->
          coll.save profile, (err, result) ->
            ll 'saved', profile
            socket.emit 'topic-add', 'ok'
            socket.broadcast.to('topics').emit 'topic-inc', profile
        'mongo...'

    reply 'topic-enter', (j) -> if timing()
      if not j? then 'where s data'
      else if not j.mark? then 'where s mark'
      else if typeof j.mark isnt 'string' then 'mark wants string'
      else if me.room is j.mark then 'already here' else
        db.collection 'posts', (err, coll) ->
          coll.find({topic:j.mark}).toArray (err, list) ->
            socket.emit 'topic-enter', list
        join j.mark
        'mongo...'

    reply 'post-open', -> if timing()
      if me.thread? then 'thread already on'
      else if me.room is 'topics' then 'cant post as topic' else
        me.thread = stemp()
        {mark: me.thread}

    reply 'post-close', (j) -> if timing()
      if not me.thread? then 'no thread'
      else if me.room is 'topics' then 'cant post as topic'
      else if not j? then 'where s data'
      else if not j.mark? then 'where s mark'
      else if not j.text? then 'where s text'
      else if (typeof j.text) isnt 'string' then 'mark wants string'
      else if not (1< j.text.length <40) then 'text length 1 to 40'
      else
        db.collection 'posts', (err, coll) ->
          profile =
            text: j.text
            name: me.username
            time: watch()
            mark: me.thread
            topic: me.room
          coll.save profile, (err, result) ->
            socket.emit 'post-close', 'ok'
            socket.broadcast.to(profile.topic).emit 'post-end', profile
        me.thread = undefined
        'mongo...'

    reply 'post-sync', (j) -> if timing()
      if not me.thread? then 'no thread'
      else if me.room is 'topics' then 'cant post as topic'
      else if not j? then 'where a data'
      else if not j.mark? then 'where s mark'
      else if not j.stay? then 'where s stay'
      else if not j.text? then 'where s text'
      else if (typeof j.mark) isnt 'string' then 'mark wants string'
      else if (typeof j.stay) isnt 'number' then 'mark wants number'
      else if (typeof j.text) isnt 'string' then 'mark wants string'
      else
        ll j
        socket.broadcast.to(me.room).emit 'post-sync', 'dd'
        'ok'