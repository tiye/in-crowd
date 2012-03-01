
app = (require 'express').createServer()
fs = require 'fs'
require 'sugar'
j2page = (require './lib/json2page').json2page
o = console.dir

pag_ =
  head:
    title: 'Talk'
    meta: {attr: charset: 'utf-8'}
    link:
      attr:
        rel: 'shortcut icon'
        href: '/lib/favicon.ico'
  body:
    script01:
      attr:
        src: '/pages.coffee'
        type: 'text/coffeescript'
    script0:
      attr:
        src: '/client.coffee'
        type: 'text/coffeescript'
    script2: {attr: src: '/lib/jquery-min.js'}
    script4: {attr: src: '/lib/json2page.js'}
    script5: {attr: src: '/socket.io/socket.io.js'}
    script3: {attr: src: '/lib/sugar.js'}
    script1: {attr: src: '/lib/coffee-script.js'}
page = j2page pag_

app.get '/', (req, res) ->
  res.end page
app.get '/:js', (req, res) ->
	fs.readFile req.params.js, (err, data) ->
    if err then throw err
    res.end data
app.get '/lib/:lib', (req, res) ->
  fs.readFile 'lib/'+req.params.lib, (err, data) ->
    if err then throw err
    res.end data
app.listen 8000

n = 0
db = (require 'mongojs').connect 'localhost:27017/test', ['qingtan']
db.qingtan.count (err, result) ->
  if err then throw err
  if result>1 then n = result
stemp = ->
  Date.create().format '{MM}{dd},{hh}{mm}{ss}'

io = (require 'socket.io').listen app
io.set 'log level', 1
io.set "transports", ["xhr-polling"]
io.set "polling duration", 10
io.sockets.on 'connection', (socket) ->
  socket.emit 'your_name'
  my_n = undefined
  my_name = undefined
  g = 0
  socket.join "g#{g}"
  socket.on 'my_name', (name) ->
    if name is '0'
      socket.emit 'your_name'
    else
      my_name = name
      db.qingtan.find({g: 0}).limit 100, (err, result) ->
        socket.emit 'root_page', result
        if n>0 then socket.emit 'bind_up', n-1
  socket.on 'open', ->
    my_n = n
    n += 1
    socket.emit 'give_n', my_n
    (socket.broadcast.to "g#{g}").emit 'sync_open', [my_n, my_name]
  socket.on 'close', (close_input) ->
    data =
      n: my_n
      g: g
      text: close_input
      reply: 0
      time: stemp()
      name: my_name
    if my_n is 0 then data.reply = -1
    db.qingtan.save data
    db.qingtan.find {n:g}, (err, result) ->
      data = result[0]
      (io.sockets.in "g#{data.g}").emit 'reply1', g
      #(io.sockets.in "g#{g}").emit 'reply1', g
      data.reply += 1
      db.qingtan.update {n:g}, data
  socket.on 'input', ([n, box_input]) ->
    (socket.broadcast.to "g#{g}").emit 'sync', [n, box_input]
  socket.on 'group_to', (to_g) ->
    db.qingtan.find({n:to_g}).limit 100, (err, result) ->
      if err then throw err
      if n>0 and to_g is 0
        socket.emit 'bind_up', n-1
      else
        socket.emit 'bind_up', result[0].g
      if result[0].n isnt 0
        socket.emit 'root_page', result
    db.qingtan.find({g:to_g}).limit 100, (err, result) ->
      if err then throw err
      socket.emit 'root_page', result
    socket.leave "g#{g}"
    g = to_g
    socket.join "g#{g}"
  socket.on 'search', (query) ->
    pattern = new RegExp query, 'gi'
    db.qingtan.find({text:pattern}).limit 100, (err, result) ->
      if err then throw err
      socket.emit 'root_page', result