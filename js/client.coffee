
render = (name, id, content, cls, time) ->
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
id_num = 'none'
last_name = ''
window.onload = ->
	($ '#text').hide()
	socket = io.connect window.location.hostname
	socket.emit 'set nickname', prompt 'Please input your name:'
	socket.emit 'who'
	socket.on 'unready', () ->
		socket.emit 'set nickname', prompt 'Name used, another one:'
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
							console.log 'do'
							($ '#box').empty()
				if ($ '#text').val().length > 2
					content = ($ '#text').val()
					($ '#text').slideUp(200).focus()
					text_hide = true
					socket.emit 'close', id_num, content
					id_num = 'none'
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
		tmp = '<span class="time">&nbsp;' + data.time + '</span>'
		($ '#'+data.id).text data.content
		($ '#'+data.id).append tmp
		@
	socket.on 'logs', (logs) ->
		for item in (logs.slice -5)
			if item[0] is last_name then item[0] = '&nbsp;' else last_name = item[0]
			render item[0], 'raw', item[1], 'raw', item[2]
		@
	socket.on 'who', (msg, time) ->
		render '/who', 'raw', msg, 'raw', time
	@