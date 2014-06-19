
exports.today = (time) ->
  time = new Date time
  hour = time.getHours()
  mins = time.getMinutes()
  "#{hour}:#{mins}"