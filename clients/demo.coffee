
window.onload = ->
  window.socket = io.connect '127.0.0.1:8000/chat'
