var app, check_name, data, fs, handler, io, names, o, thread, time, topic, topics, url;

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
  if (name.length < 1) return false;
  for (_i = 0, _len = names.length; _i < _len; _i++) {
    item = names[_i];
    if (item === name) return false;
  }
  names.push(name);
  return true;
};

thread = 0;

topic = 0;

topics = [0];

data = [
  {
    name: '题叶',
    text: '大家好, 这是第零条发布的消息',
    thread: 0,
    topic: 'topic0'
  }
];

io.sockets.on('connection', function(s) {
  var my_name, my_topic, ss;
  my_name = '';
  my_topic = 'topic0';
  s.join(my_topic);
  ss = io.sockets["in"](my_topic);
  s.on('auto login', function(t) {
    t.status = check_name(t.name);
    s.emit('auto login', t);
    if (t.status) return my_name = t.name;
  });
  s.on('disconnect', function() {
    var i, _ref, _results;
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
    var r;
    r = {
      'status': check_name(t.name),
      'name': t.name
    };
    if (r.status) my_name = r.name;
    my_name = t.name;
    return s.emit('send name', r);
  });
  s.on('open', function(t) {
    var r;
    thread += 1;
    r = {
      'name': my_name,
      'thread': thread
    };
    ss.emit('open', r);
    return s.emit('thread', r);
  });
  s.on('sync', function(t) {
    var r;
    r = {
      'text': t.text,
      'name': my_name,
      'thread': t.thread
    };
    return ss.emit('sync', r);
  });
  s.on('close', function(t) {
    var d, i, r, _i, _j, _len, _len2;
    r = {
      'text': t.text,
      'thread': t.thread
    };
    ss.emit('close', r);
    d = {
      'name': my_name,
      'text': t.text,
      'thread': t.thread,
      'topic': my_topic
    };
    data.push(d);
    if (d.text.length < 2) {
      for (_i = 0, _len = topics.length; _i < _len; _i++) {
        i = topics[_i];
        if (i === d.thread) topics.splice(i, 1);
      }
      data[d.thread].topic = 'none';
      s.join('topic0');
      my_topic = 'topic0';
      d = [];
      for (_j = 0, _len2 = data.length; _j < _len2; _j++) {
        i = data[_j];
        if (i.topic === my_topic) d.push(i);
      }
      r = {
        'data': d
      };
      return s.emit('new topic', r);
    }
  });
  s.on('create', function(t) {
    var r;
    thread += 1;
    topic += 1;
    s.leave(my_topic);
    my_topic = "topic" + topic;
    s.join(my_topic);
    r = {
      'name': my_name,
      'state': 'raw',
      'thread': thread,
      'topic': my_topic
    };
    topics.push(r.thread);
    ss = io.sockets["in"](my_topic);
    s.emit('new topic', {});
    ss.emit('open', r);
    s.emit('thread', r);
    return ss.emit('create', r);
  });
  s.on('join', function(t) {
    var d, i, r, _i, _len;
    s.leave(my_topic);
    my_topic = t.topic;
    s.join(my_topic);
    d = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      i = data[_i];
      if (i.topic === my_topic) d.push(i);
    }
    r = {
      'data': d
    };
    ss = io.sockets["in"](my_topic);
    return s.emit('new topic', r);
  });
  return s.on('topic history', function(t) {
    var d, i, r, _i, _len;
    d = [];
    for (_i = 0, _len = topics.length; _i < _len; _i++) {
      i = topics[_i];
      r = {
        'text': data[i].text,
        'thread': data[i].thread,
        'topic': data[i].topic
      };
      d.push(r);
    }
    return s.emit('topic history', d);
  });
});
