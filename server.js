var app, fs, groups_data, handler, io, list_thread, new_list_thread, new_thread, o, post_data, request, thread, timestamp, url;

request = require('request');

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

thread = 0;

new_thread = function() {
  thread += 1;
  return thread;
};

list_thread = 0;

new_list_thread = function() {
  list_thread += 1;
  return list_thread;
};

timestamp = function() {
  var t, tm;
  t = new Date();
  return tm = t.getMonth() + '-' + t.getDate() + ' ' + t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
};

groups_data = [['content', 'jiyinyiyong@gmail.com', 'time']];

post_data = [];

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
    (io.sockets["in"](current_room)).emit('close post', thread_id, post_content);
    if (post_content !== '') {
      return post_data.push([current_room, thread_id, post_content, timestamp(), username]);
    }
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
      var item, new_list, _i, _len;
      username = body.email;
      socket.emit('list groups', groups_data);
      socket.leave('public room');
      socket.join('list');
      socket.join('list_id00');
      current_room = 'list_id00';
      new_list = [];
      for (_i = 0, _len = post_data.length; _i < _len; _i++) {
        item = post_data[_i];
        if (item[0] === current_room) new_list.push(item);
      }
      return socket.emit('join', new_list);
    });
  });
  /*
  	setTimeout (->
  		username = 'jiyinyiyong@gmail'
  		socket.emit 'list groups', groups_data
  		socket.leave 'public room'
  		socket.join 'list'
  		o 'sent list groups msg'
  		socket.join 'list_id00'), 200
  	# finish auto login here
  */
  socket.on('logout', function() {
    var item, new_list, _i, _len;
    username = 'name_missing';
    socket.leave('list');
    current_room = 'public room';
    socket.join(current_room);
    new_list = [];
    for (_i = 0, _len = post_data.length; _i < _len; _i++) {
      item = post_data[_i];
      if (item[0] === current_room) new_list.push(item);
    }
    return socket.emit('already logout', new_list);
  });
  socket.on('add title', function(title_data) {
    return (io.sockets["in"]('list')).emit('add title', title_data, new_thread());
  });
  return socket.on('join', function(list_name) {
    var item, new_list, _i, _len;
    if (list_name !== current_room) {
      socket.join(list_name);
      socket.leave(current_room);
      current_room = list_name;
      new_list = [];
      for (_i = 0, _len = post_data.length; _i < _len; _i++) {
        item = post_data[_i];
        if (item[0] === current_room) new_list.push(item);
      }
      return socket.emit('join', new_list);
    }
  });
});
