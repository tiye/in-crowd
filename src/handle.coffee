
nav = "
  <p> Topic List </p>
  <p> Set Name </p>
  "

$ ->
  h = $ '#nav'
  b = $ '#box'
  view = 'room' # 'topic' 'name' 'nav'
  h.click ->
    console.log nav
    b.html nav