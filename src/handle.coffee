
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

post_box = (data) ->
  if data.reply? then data.reply = String data.reply
  if data.time then time = data.time else time = clock()
  t = "#{time.date or ''} #{time.time or ''}"
  id =
    if data.cid? then "cid_#{data.cid}"
    else if data.tid? then "tid_#{data.tid}" else ''

  """<div class="unit" id="#{id}">
    <header class="icon">
      <img class="icon" src="#{data.avatar_url}"/>
    </header>
    <div class="detail">
      <p class="info">
        <span class="nick"> #{data.nick or ''} </span>
        <span class="name"> #{data.login or ''} </span>
        <span class="reply"> #{data.reply or ''} </span>
        <span class="time"> #{t} </span>
      </p>
      <p class="value #{data.input or ''}">
        #{data.value or ''}
      </p>
    </div>
  </div>"""

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
s.on 'err', (err) -> show 'API ERROR: ', err

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
  $.fx.speeds._default = 200
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
        if ls.sight is 'topic'
          if found $('#topic input') then finish_topic()
          else start_topic()
        else if ls.sight is 'chat'
          if found $('#chat input') then finish_chat()
          else start_chat()

  start_topic = ->
    $('#topic').append '<input class="input"/>'
    $('#topic input').focus().hide().slideDown()

  finish_topic = ->
    input = $("#topic input")
    value = input.val().trim()
    tid = "#{ls.login}_#{mark()}"
    if value.length > 0
      s.emit 'add_topic', value, tid, clock()
    input.slideUp -> input.remove()

  start_chat = ->
    $('#chat').append '<input class="input"/>'
    ls.cid = "#{ls.login}_#{mark()}"
    input = $('#chat input').focus()
    input.bind 'input', ->
      s.emit 'chat', ls.tid, ls.cid,
        input.val().trim(), clock(), no

  finish_chat = ->
    input = $("#chat input")
    value = input.val().trim()
    s.emit 'end_chat', ls.tid, ls.cid, value, clock(), yes
    input.slideUp -> input.remove()

  login_link = -> open login_url
  logout_link = ->
    s.emit 'logout'
    preview '404', '.guest'
    logio.unbind 'click', logout_link
    logio.click login_link
    ls.removeItem 'authed'
    ls.removeItem 'key'
    logio.text 'click to login'
    
  logio = $('#config .login span')
  logio.click login_link


  preview = (avatar_url, login) ->
    $('#config img').attr 'src', avatar_url
    $('#config .unit .name').text login

  render_login = (data) ->
    preview data.avatar_url, data.login

    if data.nick?
      $('#config .nick').text data.nick
      $('#nick').val data.nick
      ls.nick = nick

    if data.value?
      $('#config .value').text data.value
      $('#value').val data.value
      ls.value = data.value

    logio.unbind 'click', login_link
    logio.click logout_link
    logio.text 'logout'

    ls.authed = 'yes'
    ls.login = data.login
    ls.avatar_url = data.avatar_url

  s.on 'login', render_login

  $('#nick').blur ->
    get_nick = $('#nick').val()[..20]
    $('#config .unit .nick').text get_nick
    s.emit 'nick', get_nick
    ls.nick = nick

  $('#value').blur ->
    get_value = $('#value').val()[..20]
    $('#config .unit .value').text get_value
    s.emit 'value', get_value
    ls.value = ls.value

  add_topic = (data) ->
    box = post_box data
    $('#topic').append(box)
    elem = $('#topic').children().last()
    elem.hide().slideDown()
    elem.click -> see_chat data.tid

  set_chat = (data) ->
    tid = data.tid
    cid = data.cid
    scope = $("#chat #scope_#{tid}")
    unless found scope
      if found $('#chat>div:visible') then hide = yes
      $("#chat").append "<div id='scope_#{tid}'/>"
      scope = $("#chat #scope_#{tid}")
      if hide then scope.hide()
    target = scope.find("#cid_#{cid}")
    if found target
      $("#chat #cid_#{cid}").find('.value').text data.value
    else
      box = post_box data
      scope.append box
      target = scope.find("#cid_#{cid}")
      target.hide().slideDown()
    if data.value.length is 0
      target.slideUp -> target.remove()

  see_chat = (tid) ->
    $('#chat>div:visible').hide()
    $("#chat #scope_#{tid}").slideDown()
    ls.tid = tid
    s.emit 'topic', tid
    elem = $('#topic .curr')
    if found elem then elem.removeClass 'curr'
    $("#topic #tid_#{tid}").addClass 'curr'

  s.on 'add_topic', add_topic
  s.on 'topic', (list) -> list.forEach set_chat
  s.on 'chat', (data) -> set_chat data
  s.on 'end_chat', (data) -> set_chat data

  s.on 'start_page', (list, book) ->
    list.forEach add_topic
    tid = $('#topic').children().last().attr('id')[4..]
    see_chat tid
    for k, v of book
      box = post_box v
      $('#name').append box

  s.on 'msg_left', (data) ->
    data.value = 'just left'
    box = post_box data
    $('#msg').append box
    target = $("#name .name:contains('#{data.login}')")
    target = target.parent().parent().parent()
    target.slideUp -> target.remove()

  s.on 'msg_login', (data) ->
    box = post_box data
    $('#name').append box
    data.value = 'just login'
    box = post_box data
    $('#msg').append box

  s.on 'msg_nick', (data) ->
    target = $("#name .name:contains('#{data.login}')")
    target = target.prev().text data.nick
    data.value = 'changed nick: ' + data.nick
    box = post_box data
    $('#msg').append box

  s.on 'msg_value', (data) ->
    target = $("#name .name:contains('#{data.login}')")
    target = target.parent().next().text data.value
    data.value = 'changed state: ' + data.value
    box = post_box data
    $('#msg').append box