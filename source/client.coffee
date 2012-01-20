
$ ->
	s = io.connect window.location.hostname
	logined = false
	my_thread = 0
	chat_page = (t) ->
		($ '#login').slideUp 100
		($ '#about').slideUp 200
		($ '#board').slideDown 200
		($.cookie 'name', t.name)
		logined = true
	login_page = ->
		($ '#board').slideUp 200
		bind_login = ->
			# o 'sending name'
			t =
				'name': ($ '#name_text').val().replace /(\s*)|(\n*)/g, ''
			s.emit 'auto login', t
		($ '#send_name').click () ->
			bind_login()
		($ '#name_text').keydown (e) ->
			if e.keyCode is 13
				bind_login()
	s.on 'send name', (t) ->
		if t.status then (chat_page t)
		else
			console.log 'name used'
			($ '#note').text('name used').slideDown 500
			setTimeout (->
				($ '#name_text').val ''
				($ '#note').slideUp 500), 500
	
	if ($.cookie 'name')
		t =
			'name': ($.cookie 'name')
		s.emit 'auto login', t
	else
		login_page()
	s.on 'auto login', (t) ->
		if t.status then (chat_page t)
		else login_page()
	
	box_open = false
	b = $ '#box'
	render_post = (t) ->
		console.log 'render 1 time'
		post =
			"<nav class='#{t.state}'
				style='
					width: 600px;
					height: 26px;
					display: -moz-box;
					display: -webkit-box;
					-moz-box-orient: horizontal;
					-webkit-box-orient: horizontal;
					'>
				<nav id='thread#{t.thread}'
					style='
						width: 500px;
						height: 26px;
						overflow: hidden;
						background: hsl(40,80%,80%);
						'>
				</nav>
				<nav class='name'
					style='
						width: 100px;
						height: 26px;
						overflow: hidden;
						background: hsl(300,80%,80%);
						'>
					#{t.name}
				</nav>
			</nav>"
		($ '#thread').append post
	($ document).keydown (e) ->
		if e.keyCode is 13 and logined
			if box_open
				b.focus().slideUp 100
				box_open = false
				t =
					'thread': my_thread
				s.emit 'close', t
			else
				b.focus().slideDown 100
				box_open = true
				s.emit 'open', {}
				my_thread = 0
				setTimeout (->
					b.val ''), 1
	s.on 'open', (t) ->
		render_post t
	s.on 'thread', (t) ->
		my_thread = t.thread
	b.bind 'input', ->
		t =
			'text': b.val()
			'thread': my_thread
		s.emit 'sync', t
	s.on 'sync', (t) ->
		console.log 'suny'
		($ "#thread#{t.thread}").text t.text
	s.on 'close', (t) ->
		($ "#thread#{t.thread}").parent().attr 'class', 'closed'