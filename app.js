var app, db, fs, io, j2page, n, o, pag_, page, stemp;

app = (require('express')).createServer();

fs = require('fs');

require('sugar');

j2page = (require('./lib/json2page')).json2page;

o = console.dir;

pag_ = {
  head: {
    title: 'Talk',
    meta: {
      attr: {
        charset: 'utf-8'
      }
    },
    link: {
      attr: {
        rel: 'shortcut icon',
        href: '/lib/favicon.ico'
      }
    }
  },
  body: {
    script01: {
      attr: {
        src: '/pages.coffee',
        type: 'text/coffeescript'
      }
    },
    script0: {
      attr: {
        src: '/client.coffee',
        type: 'text/coffeescript'
      }
    },
    script2: {
      attr: {
        src: '/lib/jquery-min.js'
      }
    },
    script4: {
      attr: {
        src: '/lib/json2page.js'
      }
    },
    script5: {
      attr: {
        src: '/socket.io/socket.io.js'
      }
    },
    script3: {
      attr: {
        src: '/lib/sugar.js'
      }
    },
    script1: {
      attr: {
        src: '/lib/coffee-script.js'
      }
    }
  }
};

page = j2page(pag_);

app.get('/', function(req, res) {
  return res.end(page);
});

app.get('/:js', function(req, res) {
  return fs.readFile(req.params.js, function(err, data) {
    if (err) throw err;
    return res.end(data);
  });
});

app.get('/lib/:lib', function(req, res) {
  return fs.readFile('lib/' + req.params.lib, function(err, data) {
    if (err) throw err;
    return res.end(data);
  });
});

app.listen(8000);

n = 0;

db = (require('mongojs')).connect('localhost:27017/test', ['qingtan']);

db.qingtan.count(function(err, result) {
  if (err) throw err;
  if (result > 1) return n = result;
});

stemp = function() {
  return Date.create().format('{MM}{dd},{hh}{mm}{ss}');
};

io = (require('socket.io')).listen(app);

io.set('log level', 1);

io.set("transports", ["xhr-polling"]);

io.set("polling duration", 10);

io.sockets.on('connection', function(socket) {
  var g, my_n, my_name;
  socket.emit('your_name');
  my_n = void 0;
  my_name = void 0;
  g = 0;
  socket.join("g" + g);
  socket.on('my_name', function(name) {
    if (name === '0') {
      return socket.emit('your_name');
    } else {
      my_name = name;
      return db.qingtan.find({
        g: 0
      }).limit(100, function(err, result) {
        socket.emit('root_page', result);
        if (n > 0) return socket.emit('bind_up', n - 1);
      });
    }
  });
  socket.on('open', function() {
    my_n = n;
    n += 1;
    socket.emit('give_n', my_n);
    return (socket.broadcast.to("g" + g)).emit('sync_open', [my_n, my_name]);
  });
  socket.on('close', function(close_input) {
    var data;
    data = {
      n: my_n,
      g: g,
      text: close_input,
      reply: 0,
      time: stemp(),
      name: my_name
    };
    if (my_n === 0) data.reply = -1;
    db.qingtan.save(data);
    return db.qingtan.find({
      n: g
    }, function(err, result) {
      data = result[0];
      (io.sockets["in"]("g" + data.g)).emit('reply1', g);
      data.reply += 1;
      return db.qingtan.update({
        n: g
      }, data);
    });
  });
  socket.on('input', function(_arg) {
    var box_input, n;
    n = _arg[0], box_input = _arg[1];
    return (socket.broadcast.to("g" + g)).emit('sync', [n, box_input]);
  });
  socket.on('group_to', function(to_g) {
    db.qingtan.find({
      n: to_g
    }).limit(100, function(err, result) {
      if (err) throw err;
      if (n > 0 && to_g === 0) {
        socket.emit('bind_up', n - 1);
      } else {
        socket.emit('bind_up', result[0].g);
      }
      if (result[0].n !== 0) return socket.emit('root_page', result);
    });
    db.qingtan.find({
      g: to_g
    }).limit(100, function(err, result) {
      if (err) throw err;
      return socket.emit('root_page', result);
    });
    socket.leave("g" + g);
    g = to_g;
    return socket.join("g" + g);
  });
  return socket.on('search', function(query) {
    var pattern;
    pattern = new RegExp(query, 'gi');
    return db.qingtan.find({
      text: pattern
    }).limit(100, function(err, result) {
      if (err) throw err;
      return socket.emit('root_page', result);
    });
  });
});
