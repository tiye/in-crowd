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

io.set("transports", ["xhr-polling"]);

io.set("polling duration", 10);

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
      'thread': thread,
      'text': '',
      'topic': my_topic
    };
    ss.emit('open', r);
    s.emit('thread', r);
    return data.push(r);
  });
  s.on('sync', function(t) {
    var r;
    r = {
      'text': t.text,
      'name': my_name,
      'thread': t.thread
    };
    ss.emit('sync', r);
    return data[r.thread].text = t.text;
  });
  s.on('close', function(t) {
    var r;
    r = {
      'text': t.text,
      'thread': t.thread
    };
    ss.emit('close', r);
    data[r.thread].text = r.text;
    if (t.text === '') return data[r.thread].topic = 'none';
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
    data.push({
      'name': my_name,
      'thread': r.thread,
      'topic': my_topic,
      'text': ''
    });
    ss = io.sockets["in"](my_topic);
    s.emit('new topic', {
      'data': []
    });
    ss.emit('open', r);
    s.emit('thread', r);
    ss.emit('create', r);
    return o('data:\n', data);
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
      if (r.text.length >= 2) d.push(r);
    }
    return s.emit('topic history', d);
  });
});
