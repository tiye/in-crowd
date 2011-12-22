var app, fs, handler, io, last_name, logs, name_log, names, port, thread, url;

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

port = process.env.PORT || 8000;

app.listen(port);

thread = 0;

last_name = '';

names = [];

name_log = function(name) {
  var n, _i, _len;
  for (_i = 0, _len = names.length; _i < _len; _i++) {
    n = names[_i];
    if (n === name) return false;
  }
  return true;
};

io = (require('socket.io')).listen(app);

logs = [];

io.set('log level', 1);

io.configure(function() {
  io.set("transports", ["xhr-polling"]);
  return io.set("polling duration", 10);
});

io.sockets.on('connection', function(socket) {
  socket.on('set nickname', function(name) {
    var data;
    if (name_log(name)) {
      socket.set('nickname', name, function() {
        socket.emit('ready');
        return socket.emit('logss', logs);
      });
      thread += 1;
      last_name = name;
      names.push(name);
      logs.push([name, '/joined/']);
      data = {
        'name': name,
        'id': 'id' + thread
      };
      socket.broadcast.emit('new_user', data);
      return socket.emit('new_user', data);
    } else {
      return socket.emit('unready');
    }
  });
  socket.on('disconnect', function() {
    return socket.get('nickname', function(err, name) {
      var data;
      thread += 1;
      logs.push([name, '/left/']);
      data = {
        'name': name,
        'id': 'id' + thread
      };
      socket.broadcast.emit('user_left', data);
      return socket.emit('user_left', data);
    });
  });
  socket.on('open', function() {
    thread += 1;
    return socket.get('nickname', function(err, name) {
      var data;
      if (name) {
        if (name === last_name) {
          name = '';
        } else {
          last_name = name;
        }
        data = {
          'name': name,
          'id': 'id' + thread
        };
        socket.broadcast.emit('open', data);
        return socket.emit('open_self', data);
      }
    });
  });
  socket.on('close', function(id_num, content) {
    socket.broadcast.emit('close', id_num);
    socket.emit('close', id_num);
    return socket.get('nickname', function(err, name) {
      return logs.push([name, content]);
    });
  });
  return socket.on('sync', function(data) {
    socket.broadcast.emit('sync', data);
    return socket.emit('sync', data);
  });
});
