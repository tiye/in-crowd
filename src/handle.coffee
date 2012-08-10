
key_up = 38
key_down = 40
key_left = 37
key_right = 39
key_esc = 27
key_enter = 13
key_add = 65

show = (args...) -> console.log.apply console, args
found = (elems) -> elems.length > 0
login_url = 'https://github.com/login/oauth/authorize' +
  '?client_id=1b9a3afb748a45643c8d'

ls = localStorage
typing = no
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
    if typing and (e.keyCode is key_esc)
      $('textarea').blur()
    else switch e.keyCode
      when key_left
        if found sight.prev() then slide_left sight.prev()
      when key_right
        if found sight.next() then slide_left sight.next()
      when key_up
        show 'key_up'
      when key_down
        show 'key_down'
    if ls.authed? then switch e.keyCode
      when key_add
        show 'key_add'

  login = -> open login_url
  logout = ->
    s.emit 'logout'
    preview '?', '?'
    logio.unbind 'click', logout
    logio.click login
    ls.removeItem 'authed'
    ls.removeItem 'key'
    logio.text 'click to login'
    
  logio = $('#config .login span')
  logio.click login

  s.on 'err', (err) -> show err

  preview = (avatar_url, login) ->
    $('#config img').attr 'src', avatar_url
    $('#config .unit .name').text login

  render_login = (data) ->
    preview data.avatar_url, data.login
    if data.nick?
      $('#config .nick').text data.nick
      $('#nick').val data.login
    if data.state?
      $('#config .state').text data.state
      $('#state').val data.state
    logio.unbind 'click', login
    logio.click logout
    ls.authed = 'yes'
    logio.text 'logout'

  s.on 'login', render_login