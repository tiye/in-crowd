
request = require 'request'
mongodb = require 'mongodb'
handler = (req, res) -> res.end 'sockets'

q = '/login/oauth/access_token' + '?' +
  'client_id=1b9a3afb748a45643c8d' + '&' +
  'client_secret=255b89d4eb1337dd7ad1b55aaf7c4f7a1c0525b9' + '&' +
  'code='
change = (token, f, s, users) ->
  url = 'https://github.com' + q + token
  request.post url: url, (e, r, b) ->
    key = b.match(/access_token=([0-9a-f]+)/)[1]
    call_data key, f, key, s, users
call_data = (code, f, key, s, users) ->
  url = 'https://api.github.com/user?access_token=' + code
  request.get url, (err, res, body) ->
    body = JSON.parse body
    f err, body, key, s, users

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
      db.collection 'posts', (err, posts) ->
        io.sockets.on 'connection', (s) ->
          each_socket s, users, topics, posts

        stemp = String (new Date().getTime())
        cast_stemp = -> io.sockets.emit 'stemp', stemp
        setInterval cast_stemp, 1000

upsert_user = (users, login, diff) ->
  criteria = login: login
  update = $set: diff
  options = upsert: true
  users.update criteria, update, options

get_login = (err, data, key, s, users) ->
  # show err, data
  if err? then s.emit 'err', 'login' else
    s.emit 'login', data
    s.emit 'key', key
    name = data.login
    s.join "user:#{name}"

    s.set 'name', name
    diff =
      avatar_url: data.avatar_url
      login: name
      key: key
    upsert_user users, name, diff

auto_login = (key, s, users) ->
  users.findOne key: key, (err, data) ->
    if err? then s.emit 'err', err else
      if data.length is 0 then s.emit 'err', 'no user' else
        show 'auto_login'
        s.set 'name', data.login
        s.emit 'login', data

each_socket = (s, users, topics, posts) ->
  s.on 'token', (token) -> change token, get_login, s, users
  s.on 'key', (key) -> auto_login key, s, users