
$(function() {
  var b, box_open, chat_page, login_page, logined, my_thread, render_post, render_topic, s, t;
  s = io.connect(window.location.hostname);
  logined = false;
  my_thread = 0;
  chat_page = function(t) {
    var r;
    ($('#login')).slideUp(100);
    ($('#about')).slideUp(200);
    ($('#board')).slideDown(200);
    $.cookie('name', t.name);
    logined = true;
    r = {};
    return s.emit('topic history', r);
  };
  login_page = function() {
    var bind_login;
    ($('#board')).slideUp(200);
    ($('#box')).focus().val('');
    bind_login = function() {
      var t;
      t = {
        'name': ($('#name_text')).val().replace(/(\s*)|(\n*)/g, '')
      };
      return s.emit('auto login', t);
    };
    ($('#send_name')).click(function() {
      return bind_login();
    });
    return ($('#name_text')).keydown(function(e) {
      if (e.keyCode === 13) return bind_login();
    });
  };
  s.on('send name', function(t) {
    if (t.status) {
      return chat_page(t);
    } else {
      console.log('name used');
      ($('#note')).text('name used').slideDown(500);
      return setTimeout((function() {
        ($('#name_text')).val('');
        return ($('#note')).slideUp(500);
      }), 500);
    }
  });
  if ($.cookie('name')) {
    t = {
      'name': $.cookie('name')
    };
    s.emit('auto login', t);
  } else {
    login_page();
  }
  s.on('auto login', function(t) {
    if (t.status) {
      return chat_page(t);
    } else {
      return login_page();
    }
  });
  box_open = false;
  b = $('#box');
  render_post = function(t) {
    var post;
    console.log('render 1 time');
    post = "<nav class='" + t.state + "'				style='					width: 600px;					height: 26px;					display: -moz-box;					display: -webkit-box;					-moz-box-orient: horizontal;					-webkit-box-orient: horizontal;					'>				<nav class='thread" + t.thread + "'					style='						width: 500px;						height: 26px;						overflow: hidden;						background: hsl(40,80%,80%);						'>";
    if (t.text) post += t.text;
    post += "				</nav>				<nav class='name'					style='						width: 100px;						height: 26px;						overflow: hidden;						background: hsl(300,80%,80%);						'>					" + t.name + "				</nav>			</nav>";
    return ($('#thread')).append(post);
  };
  ($(document)).keydown(function(e) {
    if (e.keyCode === 13 && logined) {
      if (box_open) {
        b.focus().slideUp(0);
        box_open = false;
        t = {
          'text': b.val(),
          'thread': my_thread
        };
        s.emit('close', t);
        return console.log('box open');
      } else {
        b.focus().val('').slideDown(0);
        box_open = true;
        s.emit('open', {});
        my_thread = 0;
        setTimeout((function() {
          return b.focus().val('');
        }), 0);
        return console.log('box close');
      }
    }
  });
  ($('#add')).click(function() {
    if (box_open) {
      b.focus().slideUp(0);
      box_open = false;
      t = {
        'text': b.val(),
        'thread': my_thread
      };
      s.emit('close', t);
      console.log('box open');
    }
    b.focus().slideDown(0);
    box_open = true;
    s.emit('open', {});
    my_thread = 0;
    setTimeout((function() {
      return b.focus().val('');
    }), 1);
    return console.log('box close');
  });
  s.on('open', function(t) {
    return render_post(t);
  });
  s.on('thread', function(t) {
    return my_thread = t.thread;
  });
  b.bind('input', function() {
    t = {
      'text': b.val().slice(0, 37),
      'thread': my_thread
    };
    return s.emit('sync', t);
  });
  s.on('sync', function(t) {
    console.log('suny');
    return ($(".thread" + t.thread)).text(t.text);
  });
  s.on('close', function(t) {
    return ($(".thread" + t.thread)).parent().attr('class', 'closed');
  });
  render_topic = function(t) {
    var post;
    post = "			<nav class='" + t.state + " " + t.topic + "'>				<nav class='thread" + t.thread + "'					style='						width: 500px;						height: 26px;						overflow: hidden;						background: hsl(40,80%,80%);						'>				</nav>			</nav>";
    return ($('#topic')).append(post);
  };
  ($('#create')).click(function() {
    if (box_open) {
      b.focus().slideUp(0);
      box_open = false;
      t = {
        'text': b.val(),
        'thread': my_thread
      };
      s.emit('close', t);
      console.log('box open');
    }
    return s.emit('create');
  });
  s.on('create', function(t) {
    render_topic(t);
    b.focus().slideDown(1);
    setTimeout((function() {
      return b.focus().val('');
    }), 1);
    box_open = true;
    console.log('create');
    return ($("." + t.topic)).click(function() {
      var r;
      r = {
        'topic': t.topic
      };
      return s.emit('join', r);
    });
  });
  s.on('new topic', function(t) {
    var i, _i, _len, _ref;
    ($('#thread')).empty();
    _ref = t.data;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      render_post(i);
    }
    console.log('new topic');
    return console.log(t.name);
  });
  s.on('topic history', function(t) {
    var i, post, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = t.length; _i < _len; _i++) {
      i = t[_i];
      post = "				<nav class='closed' id='" + i.topic + "'>					<nav class='thread" + i.thread + "'						style='						width: 500px;						height: 26px;						overflow: hidden;						background: hsl(40,80%,80%);						'>						" + i.text + "					</nav>				</nav>";
      ($('#topic')).append(post);
      _results.push(($("#" + i.topic)).click(function() {
        return (function(itopic) {
          var r;
          r = {
            'topic': itopic
          };
          return s.emit('join', r);
        })(i.topic);
      }));
    }
    return _results;
  });
  return s.emit('join', {
    'topic': 'topic0'
  });
});
