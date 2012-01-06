request = require 'request'
fs = require 'fs'
url = require 'url'
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
thread = 0
new_thread = () ->
	thread += 1
	return thread
timestamp = () ->
	t = new Date()
	tm = t.getMonth()+'-'+t.getDate()+' '+t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()
io = (require 'socket.io').listen app
io.set 'log level', 1
io.set "transports", ["xhr-polling"]
io.set "polling duration", 10
io.sockets.on 'connection', (socket) ->
	current_room = 'public room'
	username = 'name_missing'
	socket.join current_room
	socket.on 'open post', () ->
		(io.sockets.in current_room).emit 'open post', new_thread(), timestamp(), username
	socket.on 'close post', (thread_id, post_content) ->
		(io.sockets.in current_room).emit 'close post', thread_id, post_content
	socket.on 'sync', (sync_id, sync_data) ->
		(io.sockets.in current_room).emit 'sync', sync_id, sync_data, timestamp(), username
	socket.on 'login', (data) ->
		options =
			'url': 'https://browserid.org/verify'
			'method': 'post'
			'json':
				'assertion': data
				'audience': 'http://localhost:8000'
		request options, (err, request_res, body) ->
			username = body.email
			console.log body.email
	socket.on 'set nickname', (set_name) ->
		if (name_log set_name)
			socket.join room
			room_log 'join', room
			name = set_name
			names.push name
			socket.set 'nickname', name, () ->
				socket.emit 'ready'
				socket.emit 'logs', logs.slice -6
			thread += 1
			data =
				'name': name
				'id': 'id'+thread
				'time': timestamp()
				'room': room
			(io.sockets.in room).emit 'new_user', data
		else socket.emit 'unready'