
f2 = (num) ->
  if num < 10 then "0#{num}"
  else "#{num}"

one_day = (mark) ->
  day = new Date mark
  year = (f2 day.getFullYear())[2..3]
  month = f2 day.getMonth()
  date = f2 day.getDate()
  hour = f2 day.getHours()
  min = f2 day.getMinutes()
  that =
    str: "#{year} #{month}-#{date} #{hour}:#{min}"
    mark: String mark

socket = io.connect '127.0.0.1:8000/log'
socket.on 'has-error', (data) -> console.dir data.info
auth = (name, passwd) ->
  socket.emit 'login-auth', {name:name, auth: passwd}

$ ->
  start = 1340121600000
  step = 86400000
  current = new Date().getTime()
  jump = start
  days = $('#days')
  count = 0
  while jump < current and count < 100
    do ->
      now = one_day jump
      days.append "<li id='#{now.mark}'>#{now.str}</li>"
      $('#'+now.mark).click ->
        socket.emit 'topic-list', {mark: now.mark}
    jump += step
    count += 1

  socket.on 'topic-list', (list) ->
    $('#topics').html ''
    list.forEach (item) ->
      $('#topics').append "
        <li id='topic#{item.mark}'>
          #{item.date}-#{item.time} #{item.name}
          <i id='rm-topic#{item.mark}'>rm</i>
          <br>#{item.text}
        </li>"
      $("#topic#{item.mark}").click ->
        socket.emit 'post-list', {mark: item.mark}
      $("#rm-topic#{item.mark}").click ->
        socket.emit 'rm-topic', {mark: item.mark}
        off

  socket.on 'post-list', (list) ->
    $('#posts').html ''
    list.forEach (item) ->
      $("#posts").append "
        <li id='post#{item.mark}'>
          #{item.date}-#{item.time} #{item.name}
          <i id='rm-post#{item.mark}'>rm</i>
          <br>#{item.text}
        </li>"
      $("#rm-post#{item.mark}").click ->
        socket.emit 'rm-post', {topic: item.topic, mark: item.mark}
        off

  socket.on 'rm-topic', (data) ->
    $('#topic'+data.mark).remove()

  socket.on 'rm-post', (data) ->
    $('#post'+data.mark).remove()