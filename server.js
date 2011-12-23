var app, fs, handler, io, logs, name_log, names, thread, timestamp, url;

fs = require('fs');

url = require('url');

handler = function(req, res) {
  var path;
  path = (url.parse(req.url)).pathname;
  if (path === '/') path = '/index.html';
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

thread = 0;

names = [];

name_log = function(name) {
  var n, _i, _len;
  if (name.length > 10) return false;
  for (_i = 0, _len = names.length; _i < _len; _i++) {
    n = names[_i];
    if (n === name) return false;
  }
  return true;
};

timestamp = function() {
  var t, tm;
  t = new Date();
  return tm = t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
};

io = (require('socket.io')).listen(app);

logs = [];

io.set('log level', 1);

io.set("transports", ["xhr-polling"]);

io.set("polling duration", 10);

io.sockets.on('connection', function(socket) {
  socket.on('set nickname', function(name) {
    var data;
    if (name_log(name)) {
      socket.set('nickname', name, function() {
        socket.emit('ready');
        socket.emit('logs', logs);
        return this;
      });
      thread += 1;
      names.push(name);
      data = {
        'name': name,
        'id': 'id' + thread,
        'time': timestamp()
      };
      socket.broadcast.emit('new_user', data);
      socket.emit('new_user', data);
    } else {
      socket.emit('unready');
    }
    return this;
  });
  socket.on('disconnect', function() {
    return socket.get('nickname', function(err, name) {
      var data;
      thread += 1;
      names.splice(names.indexOf(name), 1);
      data = {
        'name': name,
        'id': 'id' + thread,
        'time': timestamp()
      };
      socket.broadcast.emit('user_left', data);
      return this;
    });
  });
  socket.on('open', function() {
    thread += 1;
    return socket.get('nickname', function(err, name) {
      var data;
      if (name) {
        data = {
          'name': name,
          'id': 'id' + thread,
          'time': timestamp()
        };
        socket.broadcast.emit('open', data);
        socket.emit('open_self', data);
      }
      return this;
    });
  });
  socket.on('close', function(id_num, content) {
    socket.broadcast.emit('close', id_num);
    socket.emit('close', id_num);
    socket.get('nickname', function(err, name) {
      logs.push([name, content, timestamp()]);
      return this;
    });
    return this;
  });
  socket.on('sync', function(data) {
    socket.get('nickname', function(err, name) {
      if (err) return this;
      data.time = timestamp();
      data.name = name;
      data.content = data.content.slice(0, 60);
      socket.broadcast.emit('sync', data);
      socket.emit('sync', data);
      return this;
    });
    return this;
  });
  socket.on('who', function() {
    var msg;
    if (names.length < 8) msg = names + '...' + names.length;
    if (names.length >= 8) msg = (names.slice(0, 8)) + '...' + names.length;
    socket.emit('who', msg, timestamp());
    return this;
  });
  return this;
});
