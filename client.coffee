
ll = (v...) -> console.log vi for vi in v

socket = io.connect window.location.hostname
tag = (id) -> document.getElementById id

render_login_page = ->
  page = "<textarea id='name_area'></textarea>
    <button id='send_name'>Send</button>"
  (tag 'paper').innerHTML = page
  (tag 'send_name').onclick = ->
    name = (tag 'name_area').value.trim()
    if name.length > 0
      socket.emit 'send_name', name

socket.on 'ready', ->
  if localStorage.zhongli?
    socket.emit 'send_name', localStorage.zhongli
  else
    do render_login_page
socket.on 'save_name', (user_name) ->
  localStorage.zhongli = user_name

render_topic = (arr) ->
  page = ''
  for item in arr
    page += "<tr id='topic#{item.id}'>
      <td class='topic_date'>#{item.date}</td>
      <td id='#{item.id}' class='topic_reply'>#{item.reply}</td>
      <td class='topic_author'>#{item.author}</td>
      <td class='topic_text'>#{item.text}</td>
      </tr>"
  (tag 'paper').innerHTML = "<table>#{page}</table>"

socket.on 'topic_arr', (topic_arr) ->
  render_topic topic_arr