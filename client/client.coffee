
o = (args...) ->
  console.log args
stemp = ->
  Date.create().format '{MM}{dd},{hh}{mm}{ss}'

qingtan.n = 1
qingtan.box_open = false
qingtan.g = 0

socket = io.connect window.location.hostname
socket.on 'your_name', ->
  name = ''
  while name.trim() is ''
    name = prompt 'Your display name?'
  socket.emit 'my_name', name
  qingtan.my_name = name

($ 'body').keypress (e) ->
  if e.keyCode is 13
    unless qingtan.box_open
      socket.emit 'open'
      qingtan.open_box qingtan.n
      ($ "#box").bind 'input', ->
        socket.emit 'input', [qingtan.n, ($ '#box').val()]
      qingtan.box_open = true
    else
      socket.emit 'close', ($ '#box').val()
      qingtan.close_box qingtan.n
      qingtan.box_open = false
    return false

socket.on 'give_n', (n) ->
  qingtan.n = n
  ($ '#box').parent().attr 'id', "item#{n}"
socket.on 'sync_open', ([n, my_name]) ->
  say =
    n: n
    text: ''
    reply: 0
    time: stemp()
    name: my_name
  qingtan.append_item say
socket.on 'sync', ([n, box_input]) -> 
  ($ "#text#{n}").text box_input
  ($ "#time#{n}").text stemp()
socket.on 'root_page', (items) ->
  for i in items
    qingtan.append_item i
qingtan.group_to = (g) ->
  socket.emit 'group_to', g
  qingtan.g = g
socket.on 'bind_up', (up_g) ->
  ($ '#up').unbind 'click'
  ($ '#up').click ->
    socket.emit 'group_to', up_g
    ($ '#area').empty()
($ '#search_button').click ->
  query = ($ '#search_box').val().trim()
  if query isnt ''
    socket.emit 'search', query
    ($ '#area').empty()
    ($ '#up').unbind 'click'
    ($ '#up').click ->
      socket.emit 'group_to', qingtan.g
      ($ '#area').empty()
socket.on 'reply1', (reply_n) ->
  ($ "#reply#{reply_n}").text (Number ($ "#reply#{reply_n}").text()) + 1
  o 'reply1', reply_n