
w = io.connect()
if w?
  localStorage.removeItem 'stemp'
  w.on 'ready', -> console.log 'ready'
  counting = 0
  w.on 'stemp', (stemp) ->
    if localStorage.stemp?
      if localStorage.stemp isnt stemp then location.reload()
    else
      localStorage.stemp = stemp
      console.log stemp
    counting = 0
  count = ->
    counting += 1
    if counting >= 2 then location.reload()
    console.log counting
  setInterval count, 1000