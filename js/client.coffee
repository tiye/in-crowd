
render = (name, id, content, cls) ->
	c = '<div><nav class="name">'
	c+= name
	c+= '&nbsp;</nav><nav class="'
	c+= cls
	c+= '" id="'
	c+= id
	c+= '">'
	c+= content
	c+= '</nav></div>'
	return c
id_num = 'none'
window.onload = ->
	($ '#text').hide()
	socket = io.connect window.location.hostname
	console.log 'connect', socket
	socket.emit 'set nickname', prompt('<please input your name>')
	text_hide = true
	document.onkeypress = (e) =>
		if e.keyCode is 13
			if text_hide
				($ '#text').show().focus().val ''
				text_hide = false
				socket.emit 'open', ''
			else
				($ '#text').hide().focus()
				text_hide = true
				socket.emit 'close', id_num
				id_num = 'none'
	($ '#text').bind 'input', (e) ->
		text_content = ($ '#text').val()
		socket.emit 'sync',
			'id': id_num
			'content': text_content
	socket.on 'new_user', (data) ->
		($ '#box').append (render data.name, data.id, '/joined/', 'done')
	socket.on 'user_left', (data) ->
		($ '#box').append (render data.name, data.id, '/left/', 'done')
	socket.on 'open_self', (data) ->
		id_num = data.id
		($ '#box').append (render data.name, data.id, '', 'raw')
		$(window).scrollTop($(document).height())
		setTimeout (->
			($ '#text').val ''), 10
		$(window).scrollTop($(document).height())
	socket.on 'open', (data) ->
		($ '#box').append (render data.name, data.id, '', 'raw')
		$(window).scrollTop($(document).height())
	socket.on 'close', (id_num) ->
		($ '#'+id_num).attr 'class', 'done'
		t = new Date()
		tm = t.getDate()+'-'+t.getHours()+':'+t.getMinutes()+':'+t.getSeconds()
		tmp = ($ '#'+id_num).html() + '<span class="time">&nbsp;' + tm + '</span>'
		($ '#'+id_num).html tmp
	socket.on 'sync', (data) ->
		# console.log data
		($ '#'+data.id).html data.content