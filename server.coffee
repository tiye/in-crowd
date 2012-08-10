
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
    login = data.login
    s.join "user:#{login}"

    s.set 'login', name
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
        s.set 'login', data.login
        s.set 'nick', data.nick
        s.set 'state', data.state
        s.set 'avatar_url', data.avatar_url
        s.emit 'login', data

set_nick = (nick, s, users) ->
  s.set 'nick', nick
  s.get 'login', (err, login) ->
    diff = nick: nick
    upsert_user users, login, diff

set_state = (state, s, users) ->
  s.get 'login', (err, login) ->
    diff = state: state
    upsert_user users, login, diff

add_topic = (value, topic_id, clock, s, topics) ->
  s.get 'login', (err, login) ->
    s.get 'nick', (err, nick) ->
      s.get 'avatar_url', (err, avatar_url) ->
        data =
          login: login
          nick: nick
          clock: clock
          state: value
          avatar_url: avatar_url
          topic_id: topic_id
          reply: 0
        s.broadcast.emit 'add_topic', data
        topics.insert data

start_page = (s, topics) ->
  criteria = {}
  options = limit: 20
  topics.find(criteria, options).toArray (err, list) ->
    s.emit 'start_page', list

each_socket = (s, users, topics, posts) ->
  s.on 'token', (token) -> change token, get_login, s, users
  s.on 'key', (key) -> auto_login key, s, users
  s.on 'nick', (nick) -> set_nick nick, s, users
  s.on 'state', (state) -> set_state state, s, users
  s.on 'add_topic', (value, topic_id, clock) ->
    add_topic value, topic_id, clock, s, topics
  start_page s, topics
  s.on 'topic', (topic_id) -> show topic_id