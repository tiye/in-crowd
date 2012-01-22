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
		if item is name then return false
	names.push name
	true
thread = 1
topic = 0
topics = [1]
data = [{ name: 'leaf', text: 'nothing', thread: 1, topic: 'topic0'}]

io.sockets.on 'connection', (s) ->
	my_name = ''
	my_topic = 'topic0'
	s.join my_topic
	ss = io.sockets.in my_topic
	
	s.on 'auto login', (t) ->
		t.status = check_name t.name
		s.emit 'auto login', t
		if t.status then my_name = t.name
	s.on 'disconnect', ->
		for i in [0..names.length]
			if names[i] is my_name
				names.splice i, 1
	s.on 'send name', (t) ->
		r =
			'status': check_name t.name
		if r.status then my_name = r.name
		s.emit 'send name', r

	s.on 'open', (t) ->
		thread += 1
		r =
			'name': my_name
			'state': 'raw'
			'thread': thread
		ss.emit 'open', r
		s.emit 'thread', r
	s.on 'sync', (t) ->
		r =
			'text': t.text
			'thread': t.thread
		ss.emit 'sync', r
	s.on 'close', (t) ->
		r =
			'text': t.text
			'thread': t.thread
		ss.emit 'close', r
		d =
			'name': my_name
			'text': t.text
			'thread': t.thread
			'topic': my_topic
		data.push d
	
	s.on 'create', (t) ->
		thread += 1
		topic += 1
		s.leave my_topic
		my_topic = "topic#{topic}"
		s.join my_topic
		r =
			'name': my_name
			'state': 'raw'
			'thread': thread
			'topic': my_topic
		topics.push r.thread
		ss = io.sockets.in my_topic
		s.emit 'new topic', {}
		ss.emit 'open', r
		s.emit 'thread', r
		ss.emit 'create', r
	
	s.on 'join', (t) ->
		s.leave my_topic
		my_topic = t.topic
		s.join my_topic
		d = []
		for i in data
			o i, ':::', my_topic
			if i.topic is my_topic
				d.push i
		r =
			'data': d
		o 'join and data:\n', d, data
		ss = io.sockets.in my_topic
		s.emit 'new topic', r
	s.on 'topic history', (t) ->
		d = []
		for i in topics
			r =
				'text': data[i-1].text
				'thread': data[i-1].thread
				'topic': data[i-1].topic
			d.push r
		s.emit 'topic history', d