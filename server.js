var app, check_nickname, filter_posts, fs, handler, io, new_thread, new_topic, nicknames, o, post_data, request, thread, timestamp, topic_id, topics, url;

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

topic_id = 0;

new_thread = function() {
  return thread += 1;
};

new_topic = function() {
  return topic_id += 1;
};

timestamp = function() {
  var t, tm;
  t = new Date();
  return tm = t.getMonth() + '-' + t.getDate() + ' ' + t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
};

topics = [];

post_data = [];

filter_posts = function(room_name) {
  var item, new_list, _i, _len;
  new_list = [];
  for (_i = 0, _len = post_data.length; _i < _len; _i++) {
    item = post_data[_i];
    if (item[0] === room_name) new_list.push(item);
  }
  return new_list;
};

nicknames = [];

check_nickname = function(nickname, email) {
  var item, _i, _len;
  for (_i = 0, _len = nicknames.length; _i < _len; _i++) {
    item = nicknames[_i];
    if (item[0] === nickname) return false;
  }
  return nicknames.push([nickname, email]);
};

io = (require('socket.io')).listen(app);

io.set('log level', 1);

io.set("transports", ["xhr-polling"]);

io.set("polling duration", 10);

io.sockets.on('connection', function(socket) {
  var current_room, join_room, username;
  username = 'name_missing';
  current_room = 'public room';
  socket.join(current_room);
  join_room = function(room) {
    socket.leave(current_room);
    current_room = room;
    return socket.join(current_room);
  };
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
      username = body.email;
      return socket.emit('get nickname', 'A nickname:');
    });
  });
  socket.on('nickname', function(nickname) {
    if (check_nickname(nickname, username)) {
      socket.join('list');
      socket.emit('list groups', topics);
      join_room('topic_id00');
      return socket.emit('join', filter_posts(current_room));
    } else {
      return socket.emit('get nickname', 'Name Repeated..');
    }
  });
  socket.on('logout', function() {
    username = 'name_missing';
    socket.leave('list');
    join_room('public room');
    return socket.emit('already logout', filter_posts(current_room));
  });
  socket.on('add title', function(title_data) {
    (io.sockets["in"]('list')).emit('add title', title_data, new_topic());
    return topics.push([topic_id, username, timestamp(), title_data]);
  });
  socket.on('join', function(topic_room) {
    if (topic_room !== current_room) {
      join_room(topic_room);
      return socket.emit('join', filter_posts(current_room));
    }
  });
  socket.on('begin', function() {
    return socket.emit('render begin', filter_posts(current_room));
  });
  o('herehr');
  return socket.emit('get nickname', 'A nickname:');
});
