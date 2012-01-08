request = require 'request'
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

thread = 0
new_thread = () ->
	thread += 1
	return thread
list_thread = 0
new_list_thread = () ->
	list_thread += 1
	return list_thread
timestamp = () ->
	t = new Date()
	tm = t.getMonth()+'-'+t.getDate()+' '+t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()
groups_data = [
	['content', 'jiyinyiyong@gmail.com', 'time']
	]
post_data =[]

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
		if post_content != ''
			post_data.push [current_room, thread_id, post_content, timestamp(), username]
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
			socket.emit 'list groups', groups_data
			socket.leave 'public room'
			socket.join 'list'
			socket.join 'list_id00'
			current_room = 'list_id00'
			new_list = []
			for item in post_data
				if item[0] is current_room
					new_list.push item
			socket.emit 'join', new_list
	# auto login while debugging
	###
	setTimeout (->
		username = 'jiyinyiyong@gmail'
		socket.emit 'list groups', groups_data
		socket.leave 'public room'
		socket.join 'list'
		o 'sent list groups msg'
		socket.join 'list_id00'), 200
	# finish auto login here
	###
	socket.on 'logout', () ->
		username = 'name_missing'
		socket.leave 'list'
		current_room = 'public room'
		socket.join current_room
		new_list =[]
		for item in post_data
			if item[0] is current_room
				new_list.push item
		socket.emit 'already logout', new_list
	socket.on 'add title', (title_data) ->
		(io.sockets.in 'list').emit 'add title', title_data, new_thread()
	socket.on 'join', (list_name) ->
		unless list_name is current_room
			socket.join list_name
			socket.leave current_room
			current_room = list_name
			new_list = []
			for item in post_data
				if item[0] is current_room
					new_list.push item
			socket.emit 'join', new_list