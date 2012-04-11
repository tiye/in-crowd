
$ ->
  window.socket = io.connect window.location.hostname
  do g.login_image

  socket.on ''