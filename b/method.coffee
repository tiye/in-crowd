
g = {}
exports.g = g

g.echo = ->
  console.log 'echo'

script = (str) ->
  "<script src='#{str}'></script>"

fs = require 'fs'

coffeeurl = 'http://docview.cnodejs.net/libs/coffee-script.js?js'
jqueryurl = 'http://code.jquery.com/jquery-1.7.1.min.js'
socketio  = '/socket.io/socket.io.js'
browserid = 'https://browserid.org/include.js'

g.page = ->
    action = fs.readFileSync 'action.coffee', 'utf-8'
    client = fs.readFileSync 'client.coffee', 'utf-8'
    page = "<mata charset='utf-8'/><title id='title'>Debug</title>"
    page+= "<script type='text/coffeescript'>#{action}</script>"
    page+= "<script type='text/coffeescript'>#{client}</script>"
    page+= script jqueryurl
    page+= script socketio
    page+= script browserid
    page+= script coffeeurl
    page+= "<body id='body'></body>"
    page

login = require 'browserid-verifier'

g.login = (assertion, fn) ->
  login
    assertion: assertion
    audience: 'http://localhost:8000'
    fn