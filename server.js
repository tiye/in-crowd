var app, check_name, fs, handler, io, names, o, thread, time, url;

fs = require('fs');

url = require('url');

o = console.log;

handler = function(req, res) {
  var path;
  path = (url.parse(req.url)).pathname;
  if (path === '/') path = '/public/index.html';
  return fs.readFile(__dirname + path, function(err, data) {
    if (err) {
      res.writeHead(500);
      return res.end('page not found');
    } else {
      res.writeHead(200);
      return res.end(data);
    }
  });
};

app = (require('http')).createServer(handler);

app.listen(8000);

io = (require('socket.io')).listen(app);

io.set('log level', 1);

time = function() {
  var t, tm;
  t = new Date();
  return tm = t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
};

names = [];

check_name = function(name) {
  var item, _i, _len;
  if (name.length < 2) return false;
  for (_i = 0, _len = names.length; _i < _len; _i++) {
    item = names[_i];
    o('cmp: ', item, name);
    if (item === name) return false;
  }
  names.push(name);
  o(names);
  return true;
};

thread = 0;

io.sockets.on('connection', function(s) {
  var my_name, my_topic, ss;
  my_name = '';
  my_topic = 'topic0';
  s.join(my_topic);
  ss = io.sockets["in"](my_topic);
  s.on('auto login', function(t) {
    t.status = check_name(t.name);
    s.emit('auto login', t);
    o('auto login msg: ', t);
    if (t.status) return my_name = t.name;
  });
  s.on('disconnect', function() {
    var i, _ref, _results;
    o('disconnected:', names, my_name);
    _results = [];
    for (i = 0, _ref = names.length; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      if (names[i] === my_name) {
        _results.push(names.splice(i, 1));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  });
  s.on('send name', function(t) {
    t.status = check_name(t.name);
    if (t.status) my_name = t.name;
    return s.emit('send name', t);
  });
  s.on('open', function(t) {
    thread += 1;
    t = {
      'name': my_name,
      'state': 'raw',
      'thread': thread
    };
    o('open thread');
    ss.emit('open', t);
    return s.emit('thread', t);
  });
  s.on('sync', function(t) {
    return ss.emit('sync', t);
  });
  return s.on('close', function(t) {
    return ss.emit('close', t);
  });
});
