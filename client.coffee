
ll = (v...) -> console.log vi for vi in v

socket = io.connect window.location.hostname
tag = (id_name) ->
  the_tag = document.getElementById id_name
create = (obj) ->
  a_tag = document.createElement obj.tag
  a_tag.setAttribute 'id', obj.id      if obj.id?
  a_tag.setAttribute 'class', obj.clas if obj.clas?
  a_tag.innerText = obj.text           if obj.text?
  return a_tag
insert = (elem_A, elem_B) ->
  document.insertBefore elem_A, elem_B

more = tag 'more'
list = tag 'more'

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

render_list = ->