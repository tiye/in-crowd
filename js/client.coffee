
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
id_num = 'none'
window.onload = ->
	($ '#text').hide()
	socket = io.connect window.location.hostname
	socket.emit 'logs'
	socket.emit 'set nickname', prompt 'Please input your name:'
	socket.on 'unready', () ->
		socket.emit 'set nickname', prompt 'Name used, pleas choose another one:'
	text_hide = true
	document.onkeypress = (e) =>
		if e.keyCode is 13
			if text_hide
				($ '#text').show().focus().val ''
				text_hide = false
				socket.emit 'open', ''
			else
				content = ($ '#text').val()
				($ '#text').hide().focus()
				text_hide = true
				socket.emit 'close', id_num, content
				id_num = 'none'
		else
			if text_hide
				($ '#text').show().focus().val ''
				text_hide = false
				socket.emit 'open', ''
	($ '#text').bind 'input', (e) ->
		text_content = ($ '#text').val()
		socket.emit 'sync',
			'id': id_num
			'content': text_content
	socket.on 'new_user', (data) ->
		($ '#box').append (render data.name, data.id, '/joined/', 'sys')
	socket.on 'user_left', (data) ->
		($ '#box').append (render data.name, data.id, '/left/', 'sys')
	socket.on 'open_self', (data) ->
		id_num = data.id
		($ '#box').append (render data.name, data.id, '', 'raw')
		$(window).scrollTop($(document).height())
		setTimeout (->
			($ '#text').val ''), 10
		$(window).scrollTop($(document).height())
	socket.on 'open', (data) ->
		console.log 'on open'
		($ '#box').append (render data.name, data.id, '', 'raw')
		$(window).scrollTop($(document).height())
	socket.on 'close', (id_num) ->
		($ '#'+id_num).attr 'class', 'done'
	socket.on 'sync', (data) ->
		# console.log data
		t = new Date()
		tm = t.getDate()+'-'+t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()
		tmp = '<span class="time">&nbsp;' + tm + '</span>'
		($ '#'+data.id).text data.content
		($ '#'+data.id).append tmp
	socket.on 'loging', (logs) ->
		console.log 'got: ', logs
		for item in logs
			console.log item
			($ '#box').append (render item[0], 'raw', item[1], 'raw')