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
    } else {
      localStorage.stemp = stemp;
      console.log(stemp);
    }
    return counting = 0;
  });
  count = function() {
    counting += 1;
    if (counting >= 2) location.reload();
    return console.log(counting);
  };
  setInterval(count, 1000);
}
