
console.log 'began'
fs = require 'fs'
url = require 'url'
handler = (req, res) ->
	path = (url.parse req.url).pathname
	if path is '/' then path = '/index.html'
	fs.readFile __dirname+path, (err, data)->
		console.log 'reading file', 
		if err
			res.writeHead 500
			res.end 'page not found'
		else
			res.writeHead 200
			res.end data
app = (require 'http').createServer handler
port = process.env.PORT || 8000
app.listen port
thread = 0
last_name =''
io = (require 'socket.io').listen app
io.configure () ->
	io.set 'log level', 1
	io.set "transports", ["xhr-polling"]
	io.set "polling duration", 10
io.sockets.on 'connection', (socket) ->
	socket.on 'set nickname', (name) ->
		socket.set 'nickname', name, () ->
			socket.emit 'ready'
		thread += 1
		console.log thread
		data =
			'name': name
			'id': 'id'+thread
		socket.broadcast.emit 'new_user', data
		socket.emit 'new_user', data
	socket.on 'disconnect', () ->
		thread += 1
		socket.get 'nickname', (err, name) ->
			data =
				'name': name
				'id': 'id'+thread
			socket.broadcast.emit 'user_left', data
			socket.emit 'user_left', data
	socket.on 'open', () ->
		thread += 1
		console.log 'here got "open" command, so thread = ', thread 
		socket.get 'nickname', (err, name) ->
			if name is last_name
				name = ''
			else
				last_name = name
			data =
				'name': name
				'id': 'id'+thread
			socket.broadcast.emit 'open', data
			socket.emit 'open_self', data
	socket.on 'close', (id_num) ->
		socket.broadcast.emit 'close', id_num
		socket.emit 'close', id_num
	socket.on 'sync', (data) ->
		socket.broadcast.emit 'sync', data
		socket.emit 'sync', data