
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
app.listen 8000
thread = 0
io = (require 'socket.io').listen app
io.sockets.on 'connection', (socket) ->
	socket.on 'set nickname', (name) ->
		socket.set 'nickname', name, () ->
			socket.emit 'ready'
		thread += 1
		data =
			'name': name
			'id': 'id'+thread
		socket.broadcast.emit 'new_user', data
		socket.emit 'new_user', data
	socket.on 'disconnect', () ->
		socket.get 'nickname', (err, name) ->
			thread += 1
			data =
				'name': name
				'id': 'id'+thread
			socket.broadcast.emit 'user_left', data
			socket.emit 'user_left', data
	socket.on 'open', () ->
		socket.get 'nickname', (err, name) ->
			thread += 1
			data =
				'name': name
				'id': 'id'+thread
			socket.broadcast.emit 'open', data
			socket.emit 'open', data
	socket.on 'close', (id_num) ->
		socket.broadcast.emit 'close', id_num
		socket.emit 'close', id_num
	socket.on 'sync', (data) ->
		socket.broadcast.emit 'sync', data
		socket.emit 'sync', data