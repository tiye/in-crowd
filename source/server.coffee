fs = require 'fs'
url = require 'url'
o = console.log
handler = (req, res) ->
	path = (url.parse req.url).pathname
	if path is '/' then path = '/public/index.html'
	fs.readFile __dirname+path, (err, data)->
		if err
			res.writeHead 500
			res.end 'page not found'
		else
			res.writeHead 200
			res.end data
app = (require 'http').createServer handler
app.listen 8000
io = (require 'socket.io').listen app
io.set 'log level', 1
# io.set "transports", ["xhr-polling"]
# io.set "polling duration", 10

time = () ->
	t = new Date()
	tm = t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()
names = []
check_name = (name) ->
	if name.length < 2 then return false
	for item in names
		o 'cmp: ', item, name
		if item is name then return false
	names.push name
	o names
	true
thread = 0

io.sockets.on 'connection', (s) ->
	my_name = ''
	my_topic = 'topic0'
	s.join my_topic
	ss = io.sockets.in my_topic
	
	s.on 'auto login', (t) ->
		t.status = check_name t.name
		s.emit 'auto login', t
		o 'auto login msg: ', t
		if t.status then my_name = t.name
	s.on 'disconnect', ->
		o 'disconnected:', names, my_name
		for i in [0..names.length]
			if names[i] is my_name
				names.splice i, 1
	s.on 'send name', (t) ->
		t.status = check_name t.name
		if t.status then my_name = t.name
		s.emit 'send name', t

	s.on 'open', (t) ->
		thread += 1
		t =
			'name': my_name
			'state': 'raw'
			'thread': thread
		o 'open thread'
		ss.emit 'open', t
		s.emit 'thread', t
	s.on 'sync', (t) ->
		ss.emit 'sync', t
	s.on 'close', (t) ->
		ss.emit 'close', t