
stemp = ''
do refresh = ->
  console.log '%%%%%%%%%%%%'
  s = new Date().getTime()
  stemp = String s

echo = console.log
output = (error, stdout, stderr) ->
  echo stdout
  echo stderr
  echo error if error?
  do refresh

{exec} = require 'child_process'
fs = require 'fs'
fs.watchFile 'src/handle.coffee', ->
  exec 'coffee -o app/ -bc src/handle.coffee', {}, output
fs.watchFile 'src/s.styl', ->
  exec 'stylus -o app/ src/s.styl', {}, output
fs.watchFile 'src/index.jade', ->
  exec 'jade -O app/ --pretty src/*jade', {}, output

url = require 'url'
handler = (req, res) ->
  pathname = (url.parse req.url).pathname
  switch pathname
    when '/' or '/index.html'
      fs.readFile 'app/index.html', 'utf-8', (err, data) ->
        res.end data
    when '/s.css'
      fs.readFile 'app/s.css', 'utf-8', (err, data) ->
        res.end data
    when '/handle.js'
      fs.readFile 'app/handle.js', 'utf-8', (err, data) ->
        res.end data
    else res.end 'not here'

http = require 'http'
app = http.createServer handler
io = (require 'socket.io').listen app
app.listen 8001
io.set 'log level', 1
io.set "transports", ["xhr-polling"]
io.set "polling duration", 10

io.sockets.on 'connection', (s) ->
  s.emit 'ready'
  console.log 'connection'

cast_stemp = -> io.sockets.emit 'stemp', stemp
setInterval cast_stemp, 1000