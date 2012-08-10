
key_pgup = 33
key_pgdown = 34
key_up = 38
key_down = 40
key_left = 37
key_right = 39
key_esc = 27
key_enter = 13
key_add = 65

mark = -> String (new Date().getTime())
format2 = (num) ->
  if num<10 then '0'+(String num) else (String num)
clock = ->
  now    = new Date()
  month  = format2 (now.getMonth() + 1)
  date   = format2 now.getDate()
  hour   = format2 now.getHours()
  minute = format2 now.getMinutes()
  {
    date: "#{month}/#{date}"
    time: "#{hour}:#{minute}"
  }

show = (args...) -> console.log.apply console, args
found = (elems) -> elems.length > 0
login_url = 'https://github.com/login/oauth/authorize' +
  '?client_id=1b9a3afb748a45643c8d'

ls = localStorage
sight = undefined

slide_tag = (value) ->
  if value? then ls.sight = value
  else ls.sight

slide_left = (next) ->
  left = next.offset().left - 20
  $('body').animate {scrollLeft: left}, ->
    sight = next
    slide_tag sight.attr('id')

s = io.connect 'http://localhost:8002'

addEventListener 'message', (child) ->
  token = child.data.match(/code=([0-9a-f]+)/)[1]
  s.emit 'token', token

s.on 'stemp', (stemp) ->
  if ls.server_stemp?
    if ls.server_stemp isnt stemp
      ls.server_stemp = stemp
      location.reload()
  else ls.server_stemp = stemp

s.on 'key', (key) -> ls.key = key
if ls.authed? then s.emit 'key', ls.key

$ ->
  body = $('body')
  if slide_tag()?
    tag = slide_tag()
    next = $("##{tag}")
    slide_left next
  else sight = $('body').children().first()

  body.keydown (e) ->
    show e.keyCode
    switch e.keyCode
      when key_pgup
        if found sight.prev() then slide_left sight.prev()
      when key_pgdown
        if found sight.next() then slide_left sight.next()
      when key_up
        show 'key_up'
      when key_down
        show 'key_down'
    if ls.authed? then switch e.keyCode
      when key_enter
        if ls.sight is 'topic' then toggle_topic()
        else if ls.sight is 'chat' then toggle_chat()

  post_box = (data) ->
    if data.reply? then data.reply = String data.reply
    if data.time then time = data.time else
      time = clock()
    t = "#{time.date or ''} #{time.time or ''}"

    me = """<input class="state"></input>"""
    other = """<p class="state" id="#{data.topic_id or ''}">
      #{data.state or ''}</p>"""
    """<div class="unit">
      <header class="icon">
        <img class="icon" src="#{data.avatar_url}"/>
      </header>
      <div class="detail">
        <p class="info">
          <span class="nick">
            #{data.nick or ''}
          </span>
          <span class="name">
            #{data.login or ''}
          </span>
          <span class="reply">
            #{data.reply or ''}
          </span>
          <span class="time">
            #{t}
          </spam>
        </p>
        #{if data.nick is '.me' then me else other}
      </div>
    </div>"""

  toggle_topic = ->
    if found $("#topic input")
      elem = $("#topic input")
      value = elem.val().trim()
      if value.length is 0
        parent = elem.parent().parent()
        parent.slideUp -> parent.remove()
      else
        elem[0].outerHTML = "<div class='state'>" +
          value + "</div>"
        s.emit 'add_topic', value, ls.topic_id, clock()
    else
      box = post_box {
        avatar_url: ls.avatar_url
        nick: '.me'
        reply: 0
      }
      $("#topic").append(box)
        .children().last().hide().slideDown()
      input = $("#topic input").focus()
      tmp = ls.topic_id = "#{ls.login}_#{mark()}"
      input.parent().click -> s.emit 'topic', tmp


  login_link = -> open login_url
  logout_link = ->
    s.emit 'logout'
    preview '?', '?'
    logio.unbind 'click', logout_link
    logio.click login_link
    ls.removeItem 'authed'
    ls.removeItem 'key'
    logio.text 'click to login'
    
  logio = $('#config .login span')
  logio.click login_link

  s.on 'err', (err) -> show err

  preview = (avatar_url, login) ->
    $('#config img').attr 'src', avatar_url
    $('#config .unit .name').text login

  render_login = (data) ->
    preview data.avatar_url, data.login
    if data.nick?
      $('#config .nick').text data.nick
      $('#nick').val data.nick
    if data.state?
      $('#config .state').text data.state
      $('#state').val data.state
    logio.unbind 'click', login_link
    logio.click logout_link
    ls.authed = 'yes'
    ls.login = data.login
    logio.text 'logout'
    ls.avatar_url = data.avatar_url

  s.on 'login', render_login

  $('#nick').blur ->
    get_nick = $('#nick').val()[..20]
    $('#config .unit .nick').text get_nick
    s.emit 'nick', get_nick

  $('#state').blur ->
    get_state = $('#state').val()[..20]
    $('#config .unit .state').text get_state
    s.emit 'state', get_state

  s.on 'add_topic', (data) ->
    box = post_box data
    elem = $("#topic").append(box).children().last()
    elem.hide().slideDown ->
      $("##{data.topic_id}").parent().click ->
        s.emit 'topic', data.topic_id

  s.on 'start_page', (list) ->
    list.forEach (data) ->
      box = post_box data
      elem = $("#topic").append(box).children().last()
      elem.hide().slideDown ->
        $("##{data.topic_id}").parent().click ->
          s.emit 'topic', data.topic_id