
$ ->
  # window.socket = io.connect '127.0.0.1:8000/chat'
  window.socket = io.connect 'http://zhongli.cnodejs.net:80/chat'
  
  warning = undefined
  error_handler = (data) ->
    # console.log data
    if warning? then clearTimeout warning
    do ->
      $('#warning').text data.info
      $('.alert').slideDown()
      warning = setTimeout (-> ($ '.alert').slideUp()), 1000
  socket.on 'has-error', error_handler

  unless localStorage.name? then localStorage.name = 'Guest'
  if localStorage.name?
    socket.emit 'set-name', {name: localStorage.name.trim()}
    $('#name').val localStorage.name.trim()
  $('#name').bind 'input', ->
    socket.emit 'set-name', {name: $('#name').val().trim()}
    localStorage.name = $('#name').val().trim()

  view = 'home'
  last = ''
  point = []
  level = 0

  check_same = (a, b) ->
    an = a.length
    bn = b.length
    n = if an < bn then an else bn
    fine = yes
    head = -1
    [0...n].forEach (i) ->
      if fine and a[i] is b[i] then head = i
      else fine = no
    console.log 
    [head, b[head+1..]]

  $('#say').bind 'input', ->
    unless view is 'home'
      [head, text] = check_same last, $('#say').val()
      socket.emit 'sync-post', {head: head, text: text}
      last = $('#say').val()

  sayit = (e) ->
    if $('#say').val().trim().length is 0
      error_handler {info: 'cant send black'}
    else if view is 'home'
      socket.emit 'add-topic', {text: $('#say').val().trim()}
    else
      socket.emit 'add-post', {text: $('#say').val().trim()}
    $('#say').val ''
    last = ''

  $('#say').keydown (e) -> if e.keyCode is 13 then sayit()
  $('#send').click -> sayit()

  home_say = '';
  topic_say = '';
  draw_item = (item, link) ->
    $('<li/>').attr('id', item.mark).attr('class','item').appendTo $('#list')
    $('#'+item.mark).html "
      <span class='time'>#{item.date} #{item.time}</span>
      <span class='name'>#{item.name}</span><br>
      <span class='text' id='post#{item.mark}'>#{item.text}</span>"
    if link is yes
      $('#'+item.mark).click ->
        home_say = $('#say').val()
        console.log 'store in home_say:', home_say
        $('#say').val topic_say
        socket.emit 'post-list', {mark: item.mark}
        $('#topic').text item.text
        last = ''
        view = item.mark

  topics = []
  socket.on 'add-topic', (item) ->
    draw_item item, yes
    topics.push item
  
  home_scrolltop = 0
  $('#list').bind 'scroll', ->
    if view is 'home'
      home_scrolltop = $('#list').scrollTop()

  if localStorage.name? then $('#say').focus()
  else $('#name').focus()
  socket.emit 'topic-list'
  socket.on 'topic-list', (list) ->
    topics = list.reverse()
    topics.forEach (item) -> draw_item item, yes
    point = $('#list').children().first()
    [0...level].forEach -> point = point.next()
    point.addClass 'point'

  jump_home = ->
    topic_say = $('#say').val()
    console.log 'take from home_say:', home_say
    $('#say').val home_say
    view = 'home'
    $('#list').html ''
    topics.forEach (item) -> draw_item item, yes
    last = ''
    $('#topic').text ''
    socket.emit 'leave-topic'
    $('#list').scrollTop home_scrolltop
    point = $('#list').children().first()
    [0...level].forEach -> point = point.next()
    point.addClass 'point'
  $('#home').click jump_home

  socket.on 'post-list', (list) ->
    $('#list').html ''
    list.reverse().forEach draw_item
    $('#list').scrollTop 0
  
  put_same = (diff, base) ->
    if base.length <= diff.head
      n = diff.head - base.length
      res = diff.text
      [0..n].forEach (i) -> res = 'ᖘ' + res
      res
    else if diff.head < 0 then diff.text
    else base[..diff.head]+diff.text
  socket.on 'sync-post', (data) ->
    unless view is 'home'
      if $('#post'+data.mark).length is 0
        item =
          name: 'ᖘᖘᖘ'
          date: 'ᖘᖘ-ᖘᖘ'
          time: 'ᖘᖘ:ᖘᖘ'
          text: ''
          mark: data.mark
        draw_item item
      $('#post'+data.mark).text (put_same data, $('#post'+data.mark).text())

  socket.on 'new-post', (item) ->
    # console.log 'got new-post:', item
    draw_item item

  now = new Date()
  $('#date').text "#{now.getMonth()+1}/#{now.getDate()}"
  $('#clock').text "#{now.getHours()}:#{now.getMinutes()}"
  f2 = (num) -> if num<10 then '0'+(String num) else (String num)
  old_clock = setInterval (->
    now = new Date()
    d =
      hour: now.getHours()
      min: now.getMinutes()
    $('#clock').text (f2 d.hour) + ':' + (f2 d.min)
    ), 800

  $(document).keydown (e) ->
    # console.log e.keyCode
    if e.keyCode is 9
      $('#say').focus()
      false
    else if e.keyCode is 38 # key up
      $('#list').scrollTop ($('#list').scrollTop() - 60)
      unless point.prev().length is 0
        point.removeClass 'point'
        point = point.prev()
        level -= 1
        point.addClass 'point'
      false
    else if e.keyCode is 40 # key down
      $('#list').scrollTop ($('#list').scrollTop() + 60)
      unless point.next().length is 0
        point.removeClass 'point'
        point = point.next()
        level += 1
        point.addClass 'point'
      false
    else if e.keyCode is 27 # key esc
      if view is 'home'
        point.click()
      else
        jump_home()
      false
    # else if e.keyCode is 33 # key pgup
    #   $('#list').scrollTop ($('#list').scrollTop() - 60*6)
    #   false
    # else if e.keyCode is 34 # key pgdown
    #   $('#list').scrollTop ($('#list').scrollTop() + 60*6)
    #   false

  socket.on 'add-post', (item) ->
    console.log 'got item', item
    $('#'+item.mark+' .time').text "#{item.date} #{item.time}"
    $('#'+item.mark+' .name').text item.name
    $('#post'+item.mark).text item.text
