
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
names = []
room_names = []
rooms = {}
name_log = (name) ->
	if name.length > 10 then return false
	if name.length < 1 then return false
	for n in names
		if n is name then return false
	true	
room_log = (action, room_name) ->
	if action is 'join'
		if (room_names.indexOf room_name) >= 0
			rooms[room_name] += 1
		else
			rooms[room_name] = 1
			room_names.push room_name
	else if action is 'leave'
		rooms[room_name] -= 1
timestamp = () ->
	t = new Date()
	tm = t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()
io = (require 'socket.io').listen app
logs = []
io.set 'log level', 1
io.set "transports", ["xhr-polling"]
io.set "polling duration", 10
io.sockets.on 'connection', (socket) ->
	room = 'undefind_room'
	name = 'undefind_name'
	socket.on 'set nickname', (set_name) ->
		if (name_log set_name)
			socket.join room
			room_log 'join', room
			name = set_name
			names.push name
			socket.set 'nickname', name, () ->
				(io.sockets.in room).emit 'ready'
				(io.sockets.in room).emit 'logs', logs.slice -6
			thread += 1
			data =
				'name': name
				'id': 'id'+thread
				'time': timestamp()
				'room': room
			(io.sockets.in room).emit 'new_user', data
		else socket.emit 'unready'
	socket.on 'disconnect', () ->
		thread += 1
		names.splice (names.indexOf name), 1
		data =
			'name': name
			'id': 'id'+thread
			'time': timestamp()
			'room': room
		(io.sockets.in room).emit 'user_left', data
		room_log 'leave', room
	socket.on 'open', () ->
		thread += 1
		if name
			data =
				'name': name
				'id': 'id'+thread
				'time': timestamp()
				'room': room
			(io.sockets.in room).emit 'open', data
			socket.emit 'change_id', data.id
	socket.on 'close', (id_num, content) ->
		(io.sockets.in room).emit 'close', id_num
		logs.push [name, content, timestamp(), room]
	socket.on 'sync', (data) ->
		data.time = timestamp()
		data.name = name
		data.room = room
		data.content = data.content.slice 0, 60
		(io.sockets.in room).emit 'sync', data
	socket.on 'who', () ->
		socket.emit 'who', names, timestamp()
	socket.on 'history', () ->
		socket.emit 'history', logs
	socket.on 'room0', (room0) ->
		room = room0
	socket.on 'join', (matching) ->
		if matching is room then return @
		thread += 1
		data =
			'name': name
			'id': 'id'+thread
			'time': timestamp()
			'room': room
		(io.sockets.in room).emit 'user_left', data
		socket.leave room
		room_log 'leave', room
		room = matching
		thread += 1
		socket.join room
		data.room = room
		(io.sockets.in room).emit 'new_user', data
		room_log 'join', room
	socket.on 'where', () ->
		socket.emit 'where', room, timestamp()
	socket.on 'groups', () ->
		socket.emit 'groups', room_names, rooms, timestamp()
