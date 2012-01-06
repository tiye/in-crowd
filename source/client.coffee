text_box_off = true
socket = io.connect window.location.hostname
main = ->
	render_login_page()
	($ '#post').hide()
	my_thread = null
	document.onkeypress = (e) ->
		if e.keyCode is 13
			if text_box_off
				($ '#post').show().focus()
				text_box_off = false
				socket.emit 'open post'
				# for Chrome, will add an Enter, took me an hour..
				setTimeout (-> ($ '#post').val ''), 2
			else
				socket.emit 'close post', my_thread, ($ '#post').val()
				text_box_off = true
				($ '#post').hide().focus()
	($ '#post').bind 'input', (e) ->
		post_content = ($ '#post').val()
		socket.emit 'sync', my_thread, ($ '#post').val()
		if post_content.length > 30
			($ '#post').val (post_content.slice 0, 30)
	socket.on 'open post', (thread_id, timestamp, username) ->
		my_thread = thread_id
		render_post thread_id, timestamp, username
		try_scroll()
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
	socket.on 'list groups', (groups_data) ->
		console.log 'got msg to list groups'
		render_groups groups_data
	socket.on 'already logout', () ->
		render_login_page()
	socket.on 'add title', (title_data, list_id) ->
		($ '#left').append "<nav id='list_id#{list_id}'>#{title_data}</nav>"
		($ "#list_id#{list_id}").click () ->
			socket.emit 'join', "list_id#{list_id}"

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
	render_content = '<nav id="login_nickname"><textarea id="text_nickname">'
	render_content += '</textarea><button id="send_nickname">send</button>'
	if arg then render_content += "<br/>#{arg}"
	login_page_content += '</nav>'
	($ '#left').append login_page_content
render_post = (thread_id, timestamp, username) ->
	render_content =  "<nav id='post_id#{thread_id}' class='posted_box'>"
	render_content += "<nav class='posted_content_raw'> @ #{timestamp}</nav>"
	render_content += "<nav class='posted_username'>#{username}</nav></nav>"
	($ '#right').append render_content
	try_scroll()  
try_scroll = () ->
	if text_box_off
		if ($ '#right').scrollTop() + ($ '#right').height() + 200 > ($ '#right')[0].scrollHeight
			($ '#right').scrollTop ($ '#right')[0].scrollHeight
render_groups = (groups_data) ->
	($ '#left').empty()
	($ '#left').append "<nav id='list_id00'>jiyinyiyong, time<br/>hi my google</nav>"
	($ '#list_id00').click () ->
		socket.emit 'join', "list_id00"
	($ '#left').append "<nav id='logout'>click to logout</nav>"
	($ '#left').append "<nav><textarea id='add_title'></textarea><br/><button id='send_title'>send</button></nav>"
	($ '#send_title').click () ->
			socket.emit 'add title', ($ '#add_title').val()
			($ '#add_title').val ''
	($ '#logout').click () ->
		navigator.id.logout()
		socket.emit 'logout'

window.onload = main