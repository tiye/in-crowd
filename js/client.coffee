
render = (name, id, content, cls) ->
	c = '<div><nav class="name">'
	c+= name
	c+= '&nbsp;</nav><nav class="'
	c+= cls
	c+= '" id="'
	c+= id
	c+= '">'
	c+= content + '<span class="time">'
	t = new Date()
	tm = t.getDate()+'-'+t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()
	c+= ' </span>'+tm
	c+= '</nav></div>'
	return c
try_scroll = () ->
	if ($ '#box').scrollTop() + ($ '#box').height() + 200 > ($ '#box')[0].scrollHeight
		($ '#box').scrollTop ($ '#box')[0].scrollHeight
id_num = 'none'
last_name = ''
window.onload = ->
	($ '#text').hide()
	socket = io.connect window.location.hostname
	socket.emit 'set nickname', prompt 'Please input your name:'
	socket.on 'unready', () ->
		socket.emit 'set nickname', prompt 'Name used, pleas choose another one:'
	text_hide = true
	document.onkeypress = (e) =>
		if e.keyCode is 13
			if text_hide
				($ '#text').slideDown(200).focus().val ''
				text_hide = false
				socket.emit 'open', ''
			else
				if ($ '#text').val().length > 2
					content = ($ '#text').val()
					($ '#text').slideUp(200).focus()
					text_hide = true
					socket.emit 'close', id_num, content
					id_num = 'none'
				else
					($ '#text').val('')
		else
			if text_hide
				($ '#text').slideDown(200).focus().val ''
				text_hide = false
				socket.emit 'open', ''
	($ '#text').bind 'input', (e) =>
		t = $ '#text'
		if t.val()[0] is '\n' then t.val (t.val().slice 1)
		text_content = t.val().slice 0, 60
		socket.emit 'sync',
			'id': id_num
			'content': text_content
	($ '#text').bind 'paste', () =>
		alert 'coped this string of code, do not paste'
	socket.on 'new_user', (data) ->
		($ '#box').append (render data.name, data.id, '/joined/', 'sys')
		try_scroll()
	socket.on 'user_left', (data) ->
		($ '#box').append (render data.name, data.id, '/left/', 'sys')
		try_scroll()
	socket.on 'open_self', (data) ->
		id_num = data.id
		($ '#box').append (render data.name, data.id, '', 'raw')
		($ '#text').val ''
		try_scroll()
	socket.on 'open', (data) ->
		console.log 'on open'
		($ '#box').append (render data.name, data.id, '', 'raw')
		try_scroll()
	socket.on 'close', (id_num) ->
		($ '#'+id_num).attr 'class', 'done'
	socket.on 'sync', (data) ->
		t = new Date()
		tm = t.getDate()+'-'+t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()
		tmp = '<span class="time">&nbsp;' + tm + '</span>'
		($ '#'+data.id).text data.content
		($ '#'+data.id).append tmp
	socket.on 'logss', (logs) ->
		for item in logs
			if item[0] is last_name then item[0] = '&nbsp;' else last_name = item[0]
			($ '#box').append (render item[0], 'raw', item[1], 'raw')
			try_scroll()
