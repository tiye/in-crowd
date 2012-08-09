
request = require 'request'
handler = (req, res) -> res.end 'sockets'

q = '/login/oauth/access_token' + '?' +
  'client_id=1b9a3afb748a45643c8d' + '&' +
  'client_secret=255b89d4eb1337dd7ad1b55aaf7c4f7a1c0525b9' + '&' +
  'code='
change = (token, f) ->
  url = 'https://github.com' + q + token
  request.post url: url, (e, r, b) ->
    key = b.match(/access_token=([0-9a-f]+)/)[1]
    call_data key, f, key
call_data = (code, f, key) ->
  url = 'https://api.github.com/user?access_token=' + code
  request.get url, (err, res, body) ->
    f err, body, key

app = (require 'http').createServer handler
io = (require 'socket.io').listen app, {origins: '*:*'}
io.set 'log level', 1
app.listen 8002

show = console.log

io.sockets.on 'connection', (s) ->
  name = undefined
  authed = no
  back = (err, data, key) ->
    # show err, data
    if err? then s.emit 'err', 'login' else
      s.emit 'login', data
      s.emit 'key', key
      name = data.login
  s.on 'token', (token) -> change token, back
  s.on 'key', -> '' # search database

stemp = String (new Date().getTime())
cast_stemp = -> io.sockets.emit 'stemp', stemp
setInterval cast_stemp, 1000