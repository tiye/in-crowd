var app, fs, handler, io, last_name, port, thread, url;

console.log('began');

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

io = (require('socket.io')).listen(app);

io.configure(function() {
  io.set("transports", ["xhr-polling"]);
  return io.set("polling duration", 10);
});

io.sockets.on('connection', function(socket) {
  socket.on('set nickname', function(name) {
    var data;
    socket.set('nickname', name, function() {
      return socket.emit('ready');
    });
    thread += 1;
    data = {
      'name': name,
      'id': 'id' + thread
    };
    socket.broadcast.emit('new_user', data);
    return socket.emit('new_user', data);
  });
  socket.on('disconnect', function() {
    thread += 1;
    return socket.get('nickname', function(err, name) {
      var data;
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
    console.log('here got "open" command, so thread = ', thread);
    return socket.get('nickname', function(err, name) {
      var data;
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
    });
  });
  socket.on('close', function(id_num) {
    socket.broadcast.emit('close', id_num);
    return socket.emit('close', id_num);
  });
  return socket.on('sync', function(data) {
    socket.broadcast.emit('sync', data);
    return socket.emit('sync', data);
  });
});
