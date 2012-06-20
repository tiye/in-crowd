
$ ->
  window.socket = io.connect '127.0.0.1:8000/chat'
  
  warning = undefined
  error_handler = (data) ->
    # console.log data
    if warning? then clearTimeout warning
    do ->
      $('#warning').text data.info
      $('.alert').slideDown()
      warning = setTimeout (-> ($ '.alert').slideUp()), 1000
  socket.on 'has-error', error_handler

  if localStorage.name?
    socket.emit 'set-name', {name: localStorage.name.trim()}
    $('#name').val localStorage.name.trim()
  $('#name').bind 'input', ->
    socket.emit 'set-name', {name: $('#name').val().trim()}
    localStorage.name = $('#name').val().trim()

  view = 'home'
  last = ''
  $('#say').bind 'input', ->
    unless view is 'home'
      socket.emit 'sync-post', {head: $('#say').val()}

  sayit = (e) ->
    if $('#say').val().trim().length is 0
      error_handler {info: 'cant send black'}
    if view is 'home'
      socket.emit 'add-topic', {text: $('#say').val().trim()}
    else
      socket.emit 'add-post', {text: $('#say').val().trim()}
    $('#say').val ''

  $('#say').keydown (e) -> if e.keyCode is 13 then sayit()
  $('#send').click -> sayit()

  draw_item = (item) ->
    $('<li/>').attr('id', item.mark).attr('class','item').appendTo $('#list')
    $('#'+item.mark).html "
      <span class='time'>#{item.date} #{item.time}</span>
      <span class='name'>#{item.name}</span><br>
      <span class='text'>#{item.text}</span>"
    $('#'+item.mark).click ->
      console.log item.mark
      $('#topic').text item.text
      last = ''
      $('#say').val ''

  topics = []
  socket.on 'add-topic', (item) ->
    draw_item item
    topics.push item
  
  if localStorage.name? then $('#say').focus()
  else $('#name').focus()
  socket.emit 'topic-list'
  socket.on 'topic-list', (list) ->
    topics = list.reverse()
    topics.forEach draw_item

  $('#home').click ->
    $('#list').html ''
    topics.forEach draw_item
    last = ''
    $('#say').val ''
    $('#topic').text ''