var app, fs, groups_data, handler, io, new_thread, request, thread, timestamp, url;

request = require('request');

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

new_thread = function() {
  thread += 1;
  return thread;
};

timestamp = function() {
  var t, tm;
  t = new Date();
  return tm = t.getMonth() + '-' + t.getDate() + ' ' + t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
};

groups_data = [['content', 'jiyinyiyong@gmail.com', 'time']];

io = (require('socket.io')).listen(app);

io.set('log level', 1);

io.set("transports", ["xhr-polling"]);

io.set("polling duration", 10);

io.sockets.on('connection', function(socket) {
  var current_room, username;
  current_room = 'public room';
  username = 'name_missing';
  socket.join(current_room);
  socket.on('open post', function() {
    return (io.sockets["in"](current_room)).emit('open post', new_thread(), timestamp(), username);
  });
  socket.on('close post', function(thread_id, post_content) {
    return (io.sockets["in"](current_room)).emit('close post', thread_id, post_content);
  });
  socket.on('sync', function(sync_id, sync_data) {
    return (io.sockets["in"](current_room)).emit('sync', sync_id, sync_data, timestamp(), username);
  });
  socket.on('login', function(data) {
    var options;
    options = {
      'url': 'https://browserid.org/verify',
      'method': 'post',
      'json': {
        'assertion': data,
        'audience': 'http://localhost:8000'
      }
    };
    return request(options, function(err, request_res, body) {
      username = body.email;
      return socket.emit('list groups', groups_data);
    });
  });
  return socket.on('logout', function() {
    username = 'name_missing';
    return socket.emit('already logout');
  });
});
