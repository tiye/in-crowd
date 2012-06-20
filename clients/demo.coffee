
$ ->
  window.socket = io.connect '127.0.0.1:8000/chat'
  
  warning = undefined
  socket.on 'has-error', (data) ->
    # console.log data
    if warning? then clearTimeout warning
    do ->
      ($ '#warning').text data.info
      ($ '.alert').slideDown()
      warning = setTimeout (-> ($ '.alert').slideUp()), 1000
  
  if localStorage.name?
    socket.emit 'set-name', {name: localStorage.name}
    ($ '#name').val localStorage.name
  ($ '#name').bind 'input', ->
    socket.emit 'set-name', {name: ($ '#name').val()}
    localStorage.name = ($ '#name').val()