var count, counting, w;

w = io.connect();

if (w != null) {
  localStorage.removeItem('stemp');
  w.on('ready', function() {
    return console.log('ready');
  });
  counting = 0;
  w.on('stemp', function(stemp) {
    if (localStorage.stemp != null) {
      if (localStorage.stemp !== stemp) location.reload();
    }
    localStorage.stemp = stemp;
    return counting = 0;
  });
  count = function() {
    counting += 1;
    if (counting >= 2) return location.reload;
  };
  setInterval(count, 1000);
}
