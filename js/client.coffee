
last_name = ''
id_num = ''
render = (name, id, content, cls, time) ->
	if name is last_name then name = '' else last_name = name
	c = '<div><nav class="name">'
	c+= name
	c+= '&nbsp;</nav><nav class="'
	c+= cls
	c+= '" id="'
	c+= id
	c+= '">'
	c+= content + '<span class="time">' + time
	c+= ' </span>'
	c+= '</nav></div>'
	($ '#box').append c
	try_scroll()
	@
try_scroll = () ->
	if ($ '#box').scrollTop() + ($ '#box').height() + 200 > ($ '#box')[0].scrollHeight
		($ '#box').scrollTop ($ '#box')[0].scrollHeight
	@
get_name = (strns) ->
	a = ''
	until a.length>0 and a.length<10
		a = prompt strns
	document.cookie = 'zhongli_name='+(encodeURI a)
	a
window.onload = ->
	($ '#text').hide()
	socket = io.connect window.location.hostname
	arr = document.cookie.match ///zhongli_name=([^;]*)(;|$)///
	if arr then socket.emit 'set nickname', (decodeURI arr[1])
	else socket.emit 'set nickname', get_name '输入一个长度合适的名字'
	socket.emit 'who'
	socket.on 'unready', () ->
		socket.emit 'set nickname', get_name '被占了, 换个试试'
		@
	text_hide = true
	document.onkeypress = (e) ->
		if e.keyCode is 13
			if text_hide
				($ '#text').slideDown(200).focus().val ''
				text_hide = false
				socket.emit 'open', ''
			else
				if ($ '#text').val()[0] is '/'
					switch ($ '#text').val()
						when '/who' then socket.emit 'who'
						when '/clear'
							($ '#box').empty()
							last_name = ''
				if ($ '#text').val().length > 1
					content = ($ '#text').val()
					($ '#text').slideUp(200).focus()
					text_hide = true
					socket.emit 'close', id_num, content
					id_num = ''
				else ($ '#text').val('')
		@
	($ '#text').bind 'input', (e) ->
		t = $ '#text'
		if t.val()[0] is '\n' then t.val (t.val().slice 1)
		text_content = t.val().slice 0, 60
		socket.emit 'sync',
			'id': id_num
			'content': text_content
		@
	($ '#text').bind 'paste', () ->
		alert 'coped this string of code, do not paste'
		@
	socket.on 'new_user', (data) ->
		render data.name, data.id, '/joined/', 'sys', data.time
		@
	socket.on 'user_left', (data) ->
		render data.name, data.id, '/left/', 'sys', data.time
		@
	socket.on 'open_self', (data) ->
		id_num = data.id
		render data.name, data.id, '', 'raw', data.time
		($ '#text').val ''
		@
	socket.on 'open', (data) ->
		render data.name, data.id, '', 'raw', data.time
		@
	socket.on 'close', (id_num) ->
		($ '#'+id_num).attr 'class', 'done'
		@
	socket.on 'sync', (data) ->
		if ($ '#'+data.id)
			tmp = '<span class="time">&nbsp;' + data.time + '</span>'
			($ '#'+data.id).text data.content
			($ '#'+data.id).append tmp
		else render data.name, data.id, data.content, 'raw', data.time
		@
	socket.on 'logs', (logs) ->
		for item in (logs.slice -5)
			render item[0], 'raw', item[1], 'raw', item[2]
		@
	socket.on 'who', (msg, time) ->
		render '/who', 'raw', msg, 'raw', time
		@
	@
