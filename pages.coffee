
o = (args...) ->
  console.log args
window.qingtan = {}
stemp = ->
  Date.create().format '{MM}{dd},{hh}{mm}{ss}'

qingtan.start_page =
  css:
    body:
      background: 'white'
      'font-size': '13px'
      'line-height': '26px'
      'font-family': 'Wenquanyi Micro Hei Mono'
    textarea:
      width: '700px'
      height: '28px'
      'font-size': '13px'
      'line-height': '26px'
      resize: 'none'
      'border-width': '0px'
      margin: '0px'
      padding: '0px'
      background: 'hsl(300,80%,90%)'
      'font-family': 'Wenquanyi Micro Hei Mono'
      '-moz-box-shadow': '0px 0px 10px hsl(0,40%,50%)'
      '-webkit-box-shadow': '0px 0px 10px hsl(0,40%,50%)'
    '#area>nav:nth-child(2n)':
      background: 'hsl(160,90%,90%)'
    '#area>nav:nth-child(2n+1)':
      background: 'hsl(220,90%,90%)'
    'nav[id^=reply]:hover':
      '-webkit-box-shadow': '0px 0px 10px red'
      '-moz-box-shadow': '0px 0px 10px red'
  nav0:
    style:
      width: '1000px'
      display: '-moz-box'
      display1: '-webkit-box'
      '-webkit-box-orient': 'horizontal'
      '-moz-box-orient': 'horizontal'
    textarea:
      attr:
        id: "search_box"
    nav:
      attr:
        id: 'search_button'
      style:
        width: '120px'
        height: '26px'
        background: 'hsl(60,80%,90%)'
      text: 'Search'
    nav1:
      attr:
        id: 'up'
      style:
        width: '120px'
        height: '26px'
        background: 'hsl(240,90%,90%)'
      text: 'Up'
  nav:
    style:
      width: '1000px'
    attr:
      id: 'area'
# o (json2page qingtan.start_page)
($ 'body').append (json2page qingtan.start_page)

qingtan.textarea = (n) ->
  nav:
    attr:
      id: "item#{n}"
    style:
      display: '-moz-box'
      display1: '-webkit-box'
      '-moz-box-orient': 'horizontal'
      '-webkit-box-orient': 'horizontal'
      margin: '0px'
      padding: '0px'
    textarea:
      attr:
        id: 'box'
qingtan.open_box = (n) ->
  ($ '#area').append (json2page (qingtan.textarea n))
  ($ '#box').focus()
qingtan.close_box = (n) ->
  texts = ($ '#box').val()
  close_say =
    n: n
    text: ($ '#box').val()[0...52]
    reply: 0
    time: stemp()
    name: qingtan.my_name
  ($ "#item#{n}").empty().append (qingtan.item close_say)
  ($ "#reply#{n}").click ->
    ($ '#area').empty()
    qingtan.group_to n

qingtan.item = (say) ->
  item =
    nav1:
      attr:
        id: "text#{say.n}"
      style:
        overflow: 'hidden'
        width: 700
        height: 26
      text: say.text
    nav2:
      style:
        width: 80
      attr:
        id: "reply#{say.n}"
      text: say.reply
    nav3:
      style:
        width: 100
      attr:
        id: "time#{say.n}"
      text: say.time
    nav4:
      style:
        width: 120
      attr:
        id: "name#{say.n}"
      text: say.name
  return (json2page item)
qingtan.append_item = (say) ->
  append_item =
    nav:
      attr:
        id: "item#{say.n}"
      style:
        display: '-webkit-box'
        display1: '-moz-box'
        '-moz-box-orient': 'horizontal'
        '-webkit-box-orient': 'horizontal'
  ($ "#area").append (json2page append_item)
  ($ "#item#{say.n}").append (qingtan.item say)
  ($ "#reply#{say.n}").click ->
    ($ '#area').empty()
    qingtan.group_to say.n