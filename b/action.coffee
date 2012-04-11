
window.g = {}

imageurl = 'https://browserid.org/i/sign_in_blue.png'
g.login_image = ->
  image = document.createElement 'image'
  image.setAttribute 'src', imageurl
  image.setAttribute 'id', 'browserid'
  do ($ '#body').empty
  ($ '#body').append image
  ($ '#browserid').click ->
    navigator.id.get (assertion) ->
      socket.emit 'login_key', assertion