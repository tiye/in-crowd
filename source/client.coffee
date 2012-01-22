
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
		r = {}
		s.emit 'topic history', r
	login_page = ->
		($ '#board').slideUp 200
		($ '#box').focus().val('')
		bind_login = ->
			# o 'sending name'
			t =
				'name': ($ '#name_text').val().replace /(\s*)|(\n*)/g, ''
			s.emit 'send name', t
		($ '#send_name').click () ->
			bind_login()
		($ '#name_text').keydown (e) ->
			if e.keyCode is 13
				bind_login()
	($ '#note').slideUp 0
	s.on 'send name', (t) ->
		if t.status is true then (chat_page t)
		else
			console.log 'no'
			($ '#note').text('name used')
			($ '#note').slideDown 500
			setTimeout (->
				($ '#name_text').val ''
				($ '#note').slideUp 500), 500
		console.log 'got send'
	
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
	last_name = ''
	render_post = (t) ->
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
				<nav class='thread#{t.thread}'
					style='
						width: 500px;
						height: 26px;
						overflow: hidden;
						'>"
		if t.text then post += t.text
		post += "
				</nav>
				<nav class='name'
					style='
						width: 100px;
						height: 26px;
						overflow: hidden;
						'>"
		if t.name is last_name
			post += "&nbsp;"
		else
			post += t.name
			last_name = t.name
		post += "</nav></nav>"
		($ '#thread').append post
		scroll = ($ '#thread')
		if scroll.scrollTop()+scroll.height()-scroll[0].scrollHeight > -100
			scroll.scrollTop scroll[0].scrollHeight
	($ document).keydown (e) ->
		if e.keyCode is 13 and logined
			if box_open
				b.focus().slideUp 0
				($ '#hide').show()
				box_open = false
				t =
					'text': b.val()
					'thread': my_thread
				s.emit 'close', t
			else
				($ '#hide').hide()
				b.focus().val('').slideDown 0
				box_open = true
				s.emit 'open', {}
				setTimeout (->
					b.focus().val ''), 0
	($ '#add').click ->
		if box_open
			b.focus().slideUp 0
			box_open = false
			t =
				'text': b.val()
				'thread': my_thread
			s.emit 'close', t
		($ '#hide').hide()
		b.focus().slideDown 0
		box_open = true
		s.emit 'open', {}
		setTimeout (->
			b.focus().val ''), 1
	sync = false
	s.on 'open', (t) ->
		render_post t
	s.on 'thread', (t) ->
		my_thread = t.thread
		sync = true
	b.bind 'input', ->
		if sync
			t =
				'text': b.val().slice 0, 37
				'thread': my_thread
			s.emit 'sync', t
	s.on 'sync', (t) ->
		target = ($ ".thread#{t.thread}")
		if target
			target.text t.text
		else
			render_post t
	s.on 'close', (t) ->
		sync = false
		($ ".thread#{t.thread}").parent().attr 'class', 'closed'
		if t.text.length < 2
			($ ".thread#{t.thread}").parent().remove()
	
	render_topic = (t) ->
		post = "
			<nav class='#{t.state} #{t.topic}'>
				<nav class='thread#{t.thread}'
					style='
						width: 500px;
						height: 26px;
						overflow: hidden;
						'>
				</nav>
			</nav>"
		($ '#topic').append post
	($ '#create').click ->
		if box_open
			b.focus().slideUp 0
			box_open = false
			t =
				'text': b.val()
				'thread': my_thread
			s.emit 'close', t
		s.emit 'create'
	s.on 'create', (t) ->
		($ '#hide').hide()
		render_topic t
		b.focus().slideDown 1
		setTimeout (->
			b.focus().val ''), 1
		box_open = true
		($ ".#{t.topic}").click ->
			r =
				'topic': t.topic
			s.emit 'join', r
	s.on 'new topic', (t) ->
		last_name = ''
		($ '#thread').empty()
		for i in t.data
			render_post i
	s.on 'topic history', (t) ->
		for i in t
			((i) ->
				post = "
					<nav class='closed' id='#{i.topic}'>
						<nav class='thread#{i.thread}'
							style='
							width: 500px;
							height: 26px;
							overflow: hidden;
							'>
							#{i.text}
						</nav>
					</nav>"
				($ '#topic').append post
				($ "##{i.topic}").click ->
					r =
						'topic': i.topic
					s.emit 'join', r) i
	s.emit 'join', {'topic': 'topic0'}
