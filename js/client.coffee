
render = (name, id, content, cls) ->
	c = '<div><span class="name">'
	c+= name
	c+= ':</span><span class="'
	c+= cls
	c+= '" id="'
	c+= id
	c+= '">'
	c+= content
	c+= '</span></div>'
	return c

window.onload = ->
	($ '#text').hide()
	socket = io.connect 'http://localhost'
	socket.emit 'set nickname', prompt('<please input your name>')
	text_hide = true
	id_num = 'id'
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
				id_num = 'id'
	$('#text').keydown ->
		setTimeout (->
			text_content = ($ '#text').val()
			socket.emit 'sync',
				'id': id_num
				'content': text_content), 20
	socket.on 'new_user', (data) ->
		($ '#box').append (render data.name, data.id, '/joined/', 'done')
	socket.on 'user_left', (data) ->
		($ '#box').append (render data.name, data.id, '/left/', 'done')
	socket.on 'open', (data) ->
		id_num = data.id
		($ '#box').append (render data.name, data.id, '', 'raw')
	socket.on 'close', (id_num) ->
		($ '#'+id_num).attr 'class', 'done'
	socket.on 'sync', (data) ->
		console.log data
		($ '#'+data.id).html data.content