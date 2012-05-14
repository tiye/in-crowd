
{spawn} = require 'child_process'
{print} = require 'util'
fs = require 'fs'

file = 'clients/demo.coffee'
fs.watchFile file, (e) ->
  result = spawn 'coffee', ['-bc', file]
  msg = ''
  result.stderr.on 'data', (str) -> msg += str
  result.stderr.on 'end', -> print msg if msg.length > 1
  print new Date().getTime(), '::', 'demo.js\n'