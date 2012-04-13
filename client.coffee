
ll = (v...) -> console.log vi for vi in v

socket = io.connect window.location.hostname
tag = (id_name) ->
  the_tag = document.getElementById id_name
create = (obj) ->
  a_tag = document.createElement obj.tag
  a_tag.setAttribute 'id', obj.id      if obj.id?
  a_tag.setAttribute 'class', obj.clas if obj.clas?
  a_tag.innerHTML = obj.text           if obj.text?
  return a_tag

more = tag 'more'
list = tag 'list'
title = tag 'title'
(tag 'home').onclick = ->
  socket.emit 'home'

window_focused = yes
notification = 0
window.onblur = ->
  window_focused = off
window.onfocus = ->
  window_focused = on
  notification = 0
  title.innerText = 'Page'

render_setname_page = ->
  name_area = create tag:'textarea', id:'name_area'
  send_name = create tag:'button', id:'send_name', text:'Send Name'
  more.appendChild name_area
  more.appendChild send_name
  send_name.onclick = ->
    name_str = name_area.value.trim()
    if name_str.length > 1
      socket.emit 'send_local_name', name_str

check_local_name = ->
  if localStorage.zhongli?
    local_name = localStorage.zhongli
    if local_name.length > 1
      socket.emit 'send_local_name', local_name
      return 0
  do render_setname_page

do check_local_name

socket.on 'save_name_locally', (user_name) ->
  if user_name.length > 1
    localStorage.zhongli = user_name

time_stemp = ->
  now_date = new Date()
  month  = now_date.getMonth() + 1
  date   = now_date.getDate()
  hour   = now_date.getHours()
  minute = now_date.getMinutes()
  second = now_date.getSeconds()
  return "#{month}/#{date} #{hour}:#{minute}:#{second}"

render_add_topic = ->
  add_topic = create tag:'button', id:'add_topic', text:'add topic'
  more.appendChild add_topic
  start_add_topic = ->
    topic_area = create tag:'textarea', id:'topic_area'
    more.insertBefore topic_area, add_topic
    add_topic.innerText = 'send topic'
    end_add_topic = ->
      more.removeChild topic_area
      add_topic.innerText = 'add topic'
      add_topic.onclick = start_add_topic
    add_topic.onclick = ->
      topic_title = topic_area.value.trimRight()
      if topic_title.length > 8
        do end_add_topic
        socket.emit 'add_topic', topic_title, time_stemp()
  add_topic.onclick = start_add_topic

render_a_topic = (topic) ->
  topic_id  = "#{topic.ip}:#{topic.time}"
  each_tr   = create tag:'tr', id: topic_id
  date_td   = create tag:'td', clas:'time_td',   text:topic.time
  reply_td  = create tag:'td', clas:'reply_td',  text:topic.reply
  author_td = create tag:'td', clas:'author_td', text:topic.author
  text_td   = create tag:'td', clas:'text_td',   text:topic.text
  each_tr.appendChild date_td
  each_tr.appendChild reply_td
  each_tr.appendChild author_td
  each_tr.appendChild text_td
  list.appendChild each_tr
  (tag topic_id).onclick = ->
    socket.emit 'goto_topic', topic_id

render_topic_list = (topic_list) ->
  while list.hasChildNodes()
    list.removeChild list.lastChild
  while more.hasChildNodes()
    more.removeChild more.lastChild
  for topic_item in topic_list
    render_a_topic topic_item

socket.on 'topic_list', (topic_list) ->
  render_topic_list topic_list
  do render_add_topic
  document.onkeydown = (event) ->
    if event.keyCode is 13 then false

socket.on 'new_topic', (topic_item) ->
  render_a_topic topic_item
  notification += 1
  title.innerText = notification + ' new topics'

render_a_post = (post) ->
  post_id = "#{post.ip}:#{post.time}"
  each_tr   = create tag:'tr', id: post_id
  date_td   = create tag:'td', clas:'time_td',   text:post.time
  author_td = create tag:'td', clas:'author_td', text:post.author
  text_td   = create tag:'td', clas:'text_td',   text:post.text
  each_tr.appendChild date_td
  each_tr.appendChild author_td
  each_tr.appendChild text_td
  list.appendChild each_tr

render_post_list = (post_list) ->
  while list.hasChildNodes()
    list.removeChild list.lastChild
  while more.hasChildNodes()
    more.removeChild more.lastChild
  for post_item in post_list
    render_a_post post_item

socket.on 'post_list', (post_list) ->
  render_post_list (post_list)
  document.onkeydown = (event) ->
    if event.keyCode is 13
      if not (tag 'post_box')?
        post_box_obj =
          ip: ''
          time: time_stemp()
          author: 'me'
          text: '<textarea id="post_box"></textarea>'
        render_a_post post_box_obj
        (tag 'post_box').focus()
        socket.emit 'post_box_open', time_stemp()
        (tag 'post_box').oninput = ->
          socket.emit 'post_box_sync', (tag 'post_box').value
      else
        post_text = (tag 'post_box').value
        if post_text.length > 1
          socket.emit 'post_box_close', post_text, time_stemp()
      return false

socket.on 'new_post', (new_post) ->
  render_a_post new_post
  notification += 1
  title.innerText = notification + ' new posts'

socket.on 'refresh_post', (new_post) ->
  post_box_td = (tag 'post_box').parentNode
  post_box_td.previousSibling.innerText = new_post.author
  post_box_td.parentNode.setAttribute 'id', new_post.ip+':'+new_post.time
  post_box_td.innerText = new_post.text

socket.on 'post_box_close', (post_item) ->
  post_close_id = post_item.ip + ':' + post_item.time
  (tag post_close_id).lastChild.style.color = 'black'

socket.on 'post_box_sync', (sync_id, post_box_value) ->
  (tag sync_id).lastChild.innerText = post_box_value
  (tag sync_id).lastChild.style.color = 'hsl(210,80%,70%)'

socket.on 'increase_reply', (topic_id) ->
  reply_count = (tag topic_id).childNodes[1]
  reply_count.innerText = (Number reply_count.innerText) + 1