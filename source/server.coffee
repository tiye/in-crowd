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
topic_id = 0
topics = []
post_data = []
filter_posts = (room_name) ->
	new_list = []
	for item in post_data
		if item[0] is room_name
			new_list.push item
	return new_list
nicknames = []
check_nickname = (nickname, email) ->
	for item in nicknames
		if item[0] is nickname
			return false
	nicknames.push [nickname, email]
	return true
check_email = (email) ->
	for item in nicknames
		if item[1] is email
			return item[0]
	return false
timestamp = () ->
	t = new Date()
	tm = t.getMonth()+'-'+t.getDate()+' '+t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()

io = (require 'socket.io').listen app
io.set 'log level', 1
io.set "transports", ["xhr-polling"]
io.set "polling duration", 10
io.sockets.on 'connection', (socket) ->
	email = 'email_missing'
	username = '游客'
	current_room = 'public room'
	socket.join current_room
	join_room = (room) ->
		socket.leave current_room
		current_room = room
		socket.join current_room
	socket.on 'open post', () ->
		thread += 1
		(io.sockets.in current_room).emit 'open post', thread, timestamp(), username
		socket.emit 'set id', thread
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
			email = body.email
			already_username = check_email email
			unless already_username
				socket.emit 'get nickname', '在下面输入一个昵称:'
			else
				username = already_username
				socket.join 'list'
				socket.emit 'list groups', topics
				join_room 'topic_id00'
				socket.emit 'join', (filter_posts current_room)

	socket.on 'nickname', (set_username) ->
		if check_nickname(set_username, email)
			username = set_username
			socket.join 'list'
			socket.emit 'list groups', topics
			join_room 'topic_id00'
			socket.emit 'join', (filter_posts current_room)
		else
			socket.emit 'get nickname', '被占用了.. 换一个试试'
	socket.on 'logout', () ->
		email = 'email_missing'
		username = '已游客'
		socket.leave 'list'
		join_room 'public room'
		socket.emit 'already logout', (filter_posts current_room)
	socket.on 'add title', (title_data) ->
		topic_id += 1
		(io.sockets.in 'list').emit 'add title', title_data, topic_id, username, timestamp()
		topics.push [topic_id, username, timestamp(), title_data]
	socket.on 'join', (topic_room) ->
		unless topic_room is current_room
			join_room topic_room
			socket.emit 'join', (filter_posts current_room)
	socket.on 'begin', () ->
		socket.emit 'render begin', (filter_posts current_room)