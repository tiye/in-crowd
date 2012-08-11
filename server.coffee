
request = require 'request'
mongodb = require 'mongodb'
handler = (req, res) -> res.end 'sockets'

q = '/login/oauth/access_token' + '?' +
  'client_id=1b9a3afb748a45643c8d' + '&' +
  'client_secret=255b89d4eb1337dd7ad1b55aaf7c4f7a1c0525b9' + '&' +
  'code='

app = (require 'http').createServer handler
io = (require 'socket.io').listen app, {origins: '*:*'}
io.set 'log level', 1
app.listen 8002

show = console.log

url = 'mongodb://nodejs:nodepass@localhost:27017/zhongli'
mongodb.connect url, (err, db) ->
  db.collection 'users', (err, users) ->
    users.ensureIndex {key: 1, login:1}
    db.collection 'topics', (err, topics) ->
      db.collection 'chats', (err, chats) ->
        chats.ensureIndex {tid: 1}
        io.sockets.on 'connection', (s) ->
          each_socket s, users, topics, chats

        stemp = String (new Date().getTime())
        cast_stemp = -> io.sockets.emit 'stemp', stemp
        setInterval cast_stemp, 1000


each_socket = (s, users, topics, chats) ->
  $authed = no
  $login = ''
  $nick = ''
  $value = ''
  $avatar_url = ''
      
  upsert_user = (diff) ->
    show 'upsert_user'
    criteria = login: $login
    update = $set: diff
    options = upsert: true
    users.update criteria, update, options

  get_login = (err, data, key) ->
    show 'get_login'
    if err? then s.emit 'err', 'login' else
      s.emit 'login', data
      s.emit 'key', key
      $login = data.login
      $avatar_url = data.avatar_url
      s.join "user:#{$login}"
      diff =
        avatar_url: data.avatar_url
        login: $login
        key: key
      upsert_user diff
    
  call_data = (key) ->
    show 'call_data'
    url = 'https://api.github.com/user?access_token=' + key
    request.get url, (err, res, body) ->
      body = JSON.parse body
      get_login err, body, key

  s.on 'token', (token) ->
      url = 'https://github.com' + q + token
      request.post url: url, (e, r, b) ->
        key = b.match(/access_token=([0-9a-f]+)/)[1]
        call_data key

  s.on 'key', (key) ->
    users.findOne key: key, (err, data) ->
      if err? then s.emit 'err', err else
        if data.length is 0 then s.emit 'err', 'no user' else
          $login = data.login
          $nick = data.nick
          $value = data.value
          $avatar_url = data.avatar_url
          s.emit 'login', data

  s.on 'nick', (nick) ->
    $nick = nick
    diff = nick: nick
    upsert_user diff
  
  s.on 'value', (value) ->
    $value = value
    diff = value: value
    upsert_user diff

  s.on 'add_topic', (value, tid, clock) ->
    data =
      login: $login
      nick: $nick
      clock: clock
      value: value
      avatar_url: $avatar_url
      tid: tid
      reply: 0
    io.sockets.emit 'add_topic', data
    topics.insert data

  start_page = ->
    criteria = {}
    options = limit: 20
    topics.find(criteria, options).toArray (err, list) ->
      s.emit 'start_page', list
  start_page()

  s.on 'topic', (tid) ->
    criteria = {tid: tid}
    options = limit: 20
    chats.find(criteria, options).toArray (err, list) ->
      s.emit 'topic', list
  
  sync_chat = (tid, cid, value, clock, save) ->
    data =
      login: $login
      nick: $nick
      clock: clock
      value: value
      tid: tid
      cid: cid
      avatar_url: $avatar_url
    aim = if save then 'end_chat' else 'chat'
    io.sockets.emit aim, data
    if (value.length > 0) and save then chats.insert data
  s.on 'chat', sync_chat
  s.on 'end_chat', sync_chat