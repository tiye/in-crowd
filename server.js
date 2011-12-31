var app, fs, handler, io, logs, name_log, names, room_log, room_names, rooms, thread, timestamp, url;

fs = require('fs');

url = require('url');

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

thread = 0;

names = [];

room_names = [];

rooms = {};

name_log = function(name) {
  var n, _i, _len;
  if (name.length > 10) return false;
  if (name.length < 1) return false;
  for (_i = 0, _len = names.length; _i < _len; _i++) {
    n = names[_i];
    if (n === name) return false;
  }
  return true;
};

room_log = function(action, room_name) {
  if (action === 'join') {
    if ((room_names.indexOf(room_name)) >= 0) {
      return rooms[room_name] += 1;
    } else {
      rooms[room_name] = 1;
      return room_names.push(room_name);
    }
  } else if (action === 'leave') {
    return rooms[room_name] -= 1;
  }
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
  var name, room;
  room = 'undefind_room';
  name = 'undefind_name';
  socket.on('set nickname', function(set_name) {
    var data;
    if (name_log(set_name)) {
      socket.join(room);
      room_log('join', room);
      name = set_name;
      names.push(name);
      socket.set('nickname', name, function() {
        socket.emit('ready');
        return socket.emit('logs', logs.slice(-6));
      });
      thread += 1;
      data = {
        'name': name,
        'id': 'id' + thread,
        'time': timestamp(),
        'room': room
      };
      return (io.sockets["in"](room)).emit('new_user', data);
    } else {
      return socket.emit('unready');
    }
  });
  socket.on('disconnect', function() {
    var data;
    thread += 1;
    names.splice(names.indexOf(name), 1);
    data = {
      'name': name,
      'id': 'id' + thread,
      'time': timestamp(),
      'room': room
    };
    (io.sockets["in"](room)).emit('user_left', data);
    return room_log('leave', room);
  });
  socket.on('open', function() {
    var data;
    thread += 1;
    if (name) {
      data = {
        'name': name,
        'id': 'id' + thread,
        'time': timestamp(),
        'room': room
      };
      (io.sockets["in"](room)).emit('open', data);
      return socket.emit('change_id', data.id);
    }
  });
  socket.on('close', function(id_num, content) {
    (io.sockets["in"](room)).emit('close', id_num);
    return logs.push([name, content, timestamp(), room]);
  });
  socket.on('sync', function(data) {
    data.time = timestamp();
    data.name = name;
    data.room = room;
    data.content = data.content.slice(0, 60);
    return (io.sockets["in"](room)).emit('sync', data);
  });
  socket.on('who', function() {
    return socket.emit('who', names, timestamp());
  });
  socket.on('history', function() {
    return socket.emit('history', logs);
  });
  socket.on('room0', function(room0) {
    return room = room0;
  });
  socket.on('join', function(matching) {
    var data;
    if (matching === room) return this;
    thread += 1;
    data = {
      'name': name,
      'id': 'id' + thread,
      'time': timestamp(),
      'room': room
    };
    (io.sockets["in"](room)).emit('user_left', data);
    socket.leave(room);
    room_log('leave', room);
    room = matching;
    thread += 1;
    socket.join(room);
    data.room = room;
    (io.sockets["in"](room)).emit('new_user', data);
    return room_log('join', room);
  });
  socket.on('where', function() {
    return socket.emit('where', room, timestamp());
  });
  socket.on('groups', function() {
    return socket.emit('groups', room_names, rooms, timestamp());
  });
  return socket.on('pass', function(id_num) {
    console.log('passed', id_num);
    return (io.sockets["in"](room)).emit('pass', id_num);
  });
});
