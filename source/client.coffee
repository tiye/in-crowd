o = console.log
text_box_off = true
socket = io.connect window.location.hostname
main = ->
	render_login_page()
	($ '#post').hide().focus()
	my_thread = null
	document.onkeypress = (e) ->
		if e.keyCode is 13
			if text_box_off
				($ '#post').show()
				document.getElementById('post').focus()
				text_box_off = false
				socket.emit 'open post'
				# for Chrome, will add an Enter, took me an hour..
				setTimeout (->
					($ '#post').val ''), 2
			else
				socket.emit 'close post', my_thread, ($ '#post').val()
				text_box_off = true
				($ '#post').hide()
	($ '#post').bind 'input', (e) ->
		post_content = ($ '#post').val()
		# for Chrome, add if to filter if empty was synced..
		if post_content.length > 0
			socket.emit 'sync', my_thread, ($ '#post').val()
		if post_content.length > 30
			($ '#post').val (post_content.slice 0, 30)
	socket.on 'open post', (thread_id, timestamp, username) ->
		my_thread = thread_id
		render_post thread_id, timestamp, username
	socket.on 'close post', (id_num, post_content) ->
		console.log ($ '#post_id'+my_thread).children().first().text()
		if post_content is ''
			($ '#post_id'+my_thread).remove()
		else
			($ '#post_id'+my_thread).children().first().attr 'class', 'posted_content'
	socket.on 'sync', (sync_id, sync_data, timestamp, username) ->
		if ($ '#post_id'+sync_id)
			elem = ($ '#post_id'+sync_id).children().first()
			elem.text sync_data
			elem.append  "<span class='time'> @ #{timestamp}</span>"
	socket.on 'list groups', (topics) ->
		render_groups topics
	socket.on 'already logout', (post_data) ->
		render_login_page()
		render_posts_from post_data
	socket.on 'add title', (title_data, topic_id, username, timestamp) ->
		($ '#left').append "<nav id='topic_id#{topic_id}'>#{username}, #{timestamp}<br/>#{title_data}</nav>"
		($ "#topic_id#{topic_id}").click () ->
			socket.emit 'join', "topic_id#{topic_id}"
	socket.on 'join', (post_data) ->
		render_posts_from post_data
	socket.emit 'begin'
	socket.on 'render begin', (post_data) ->
		render_posts_from post_data
	socket.on 'get nickname', (arg) ->
		render_nickname_page(arg)

render_login_page = () ->
	($ '#left').empty()
	render_content = '<image src="https://browserid.org/i/sign_in_red.png" id="login_image"/>'
	($ '#left').append render_content
	($ '#login_image').click () ->
		navigator.id.get ((assersion) ->
			socket.emit 'login', assersion
			console.log 'sending'),
			{allowPersistent: true}
render_nickname_page = (arg) ->
	($ '#left').empty()
	render_content = "<nav id='login_nickname'>#{arg}<br/><textarea id='text_nickname'>"
	render_content += '</textarea><button id="send_nickname">用这个昵称</button></nav>'
	($ '#left').append render_content
	($ '#send_nickname').click () ->
		socket.emit 'nickname', ($ '#text_nickname').val()
render_post = (thread_id, timestamp, username, content='') ->
	render_content =  "<nav id='post_id#{thread_id}' class='posted_box'>"
	render_content += "<nav class='posted_content_raw'>#{content} @ #{timestamp}</nav>"
	render_content += "<nav class='posted_username'>#{username}</nav></nav>"
	($ '#right').append render_content
	try_scroll()
try_scroll = () ->
	# if text_box_off
	if ($ '#right').scrollTop() + ($ '#right').height() + 200 > ($ '#right')[0].scrollHeight
		($ '#right').scrollTop ($ '#right')[0].scrollHeight
render_groups = (topics) ->
	($ '#left').empty()
	($ '#left').append "<nav id='logout'>点击这个区域退出登陆</nav>"
	($ '#left').append "<nav id='topic_id00'>注册昵称, 时间戳<br/>这里是登陆后默认群组, 点击按钮一下每一栏都是一个群</nav>"
	($ '#topic_id00').click () ->
		socket.emit 'join', "topic_id00"
	($ '#logout').click () ->
		navigator.id.logout()
		socket.emit 'logout'
	($ '#left').append "<nav>添加一个话题作为群组<br/><textarea id='add_title'></textarea><br/><button id='send_title'>添加此话题</button></nav>"
	($ '#send_title').click () ->
			socket.emit 'add title', ($ '#add_title').val()
			($ '#add_title').val ''
	for item in topics
		($ '#left').append "<nav id='topic_id#{item[0]}'>#{item[1]}, #{item[2]}<br/>#{item[3]}</nav>"
		($ "#topic_id#{item[0]}").click () ->
			socket.emit 'join', "topic_id#{item[0]}"
render_posts_from = (post_data) ->
	($ '#right').empty()
	for item in post_data
		render_post item[1], item[3], item[4], item[2]

window.onload = main
