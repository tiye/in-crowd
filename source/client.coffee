
last_name = ''
id_num = ''
render = (name, id, content, cls, time, room) ->
	if name is last_name then name = '' else last_name = name
	c = '<div><nav class="name">'
	c+= name
	c+= '&nbsp;</nav><nav class="'
	c+= cls
	c+= '" id="'
	c+= id
	c+= '">'
	c+= content + '<span class="time">' + time + '@' + room
	c+= ' </span>'
	c+= '</nav></div>'
	($ '#box').append c
	try_scroll()
try_scroll = () ->
	if ($ '#box').scrollTop() + ($ '#box').height() + 200 > ($ '#box')[0].scrollHeight
		($ '#box').scrollTop ($ '#box')[0].scrollHeight
get_name = (strns) ->
	a = ''
	until a.length>0 and a.length<10
		a = prompt strns
	document.cookie = 'zhongli_name='+(encodeURI a)
	return a
window.onload = ->
	($ '#text').hide()
	socket = io.connect window.location.hostname
	room_arr = document.cookie.match ///zhongli_room=([^;]*)(;|$)///
	if room_arr
		socket.emit 'room0', (decodeURI room_arr[1])
	else
		socket.emit 'room0', '0'
	arr = document.cookie.match ///zhongli_name=([^;]*)(;|$)///
	if arr
		socket.emit 'set nickname', (decodeURI arr[1])
	else
		socket.emit 'set nickname', get_name '输入一个长度合适的名字'
	socket.emit 'who'
	socket.on 'unready', () ->
		socket.emit 'set nickname', get_name '看来需要换个名字'
	text_hide = true
	document.onkeypress = (e) ->
		if e.keyCode is 13
			if text_hide
				($ '#text').slideDown(200).focus().val ''
				text_hide = false
				socket.emit 'open', ''
			else
				if ($ '#text').val()[0] is '/'
					cmd = ($ '#text').val()
					switch cmd
						when '/who' then socket.emit 'who'
						when '/clear'
							($ '#box').empty()
							last_name = ''
						when '/forget' then document.cookie = 'zhongli_name=tolongtoberemmembered!!!'
						when '/history' then socket.emit 'history'
						when '/where' then socket.emit 'where'
						when '/groups' then socket.emit 'groups'
				if matching = (($ '#text').val().match /\/join (\S+)/)
					socket.emit 'join', matching[1]
				if ($ '#text').val().length > 0
					content = ($ '#text').val()
					($ '#text').slideUp(200).focus()
					text_hide = true
					socket.emit 'close', id_num, content
					id_num = ''
	($ '#text').bind 'input', (e) ->
		t = $ '#text'
		if t.val()[0] is '\n' then t.val (t.val().slice 1)
		text_content = t.val().slice 0, 60
		socket.emit 'sync',
			'id': id_num
			'content': text_content
	($ '#text').bind 'paste', () ->
		alert 'coped this string of code, do not paste'
	socket.on 'new_user', (data) ->
		render data.name, data.id, '::进入了群组: '+data.room+' @', 'sys', data.time, data.room
		document.cookie = 'zhongli_room='+(encodeURI data.room)
	socket.on 'user_left', (data) ->
		render data.name, data.id, '::离开了群组: '+data.room+' @', 'sys', data.time, data.room
	socket.on 'open', (data) ->
		render data.name, data.id, '', 'raw', data.time, data.room
	socket.on 'change_id', (new_id) ->
		id_num = new_id
	socket.on 'close', (id_num) ->
		($ '#'+id_num).attr 'class', 'done'
	socket.on 'sync', (data) ->
		if ($ '#'+data.id)
			tmp = '<span class="time">&nbsp;' + data.time + '@' + data.room + '</span>'
			($ '#'+data.id).text data.content
			($ '#'+data.id).append tmp
		else render data.name, data.id, data.content, 'raw', data.time
	socket.on 'logs', (logs) ->
		for item in logs
			render item[0], 'sys', item[1], 'raw', item[2], item[3]
	socket.on 'who', (msg, time) ->
		for i in msg
			render '/who', 'sys', i, 'sys', time, ''
	socket.on 'history', (logs) ->
		for item in logs
			render item[0], 'sys', item[1], 'sys', item[2], item[3]
	socket.on 'where', (room_name, time) ->
		render '/where', 'sys', '::正在'+room_name+'群@', 'sys', time, ''
	socket.on 'groups', (names, data, time) ->
		for item in names
			render '/groups', 'sys', '::群名'+item+'::人数'+data[item]+'@', 'sys', time, ''
