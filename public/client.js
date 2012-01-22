
$(function() {
  var b, box_open, chat_page, last_name, login_page, logined, my_thread, render_post, render_topic, s, sync, t;
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
      return s.emit('send name', t);
    };
    ($('#send_name')).click(function() {
      return bind_login();
    });
    return ($('#name_text')).keydown(function(e) {
      if (e.keyCode === 13) return bind_login();
    });
  };
  ($('#note')).slideUp(0);
  s.on('send name', function(t) {
    if (t.status === true) {
      chat_page(t);
    } else {
      console.log('no');
      ($('#note')).text('name used');
      ($('#note')).slideDown(500);
      setTimeout((function() {
        ($('#name_text')).val('');
        return ($('#note')).slideUp(500);
      }), 500);
    }
    return console.log('got send');
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
  last_name = '';
  render_post = function(t) {
    var post, scroll;
    post = "<nav class='" + t.state + "'				style='					width: 600px;					height: 26px;					display: -moz-box;					display: -webkit-box;					-moz-box-orient: horizontal;					-webkit-box-orient: horizontal;					'>				<nav class='thread" + t.thread + "'					style='						width: 500px;						height: 26px;						overflow: hidden;						'>";
    if (t.text) post += t.text;
    post += "				</nav>				<nav class='name'					style='						width: 100px;						height: 26px;						overflow: hidden;						'>";
    if (t.name === last_name) {
      post += "&nbsp;";
    } else {
      post += t.name;
      last_name = t.name;
    }
    post += "</nav></nav>";
    ($('#thread')).append(post);
    scroll = $('#thread');
    if (scroll.scrollTop() + scroll.height() - scroll[0].scrollHeight > -100) {
      return scroll.scrollTop(scroll[0].scrollHeight);
    }
  };
  ($(document)).keydown(function(e) {
    if (e.keyCode === 13 && logined) {
      if (box_open) {
        b.focus().slideUp(0);
        ($('#hide')).show();
        box_open = false;
        t = {
          'text': b.val(),
          'thread': my_thread
        };
        return s.emit('close', t);
      } else {
        ($('#hide')).hide();
        b.focus().val('').slideDown(0);
        box_open = true;
        s.emit('open', {});
        return setTimeout((function() {
          return b.focus().val('');
        }), 0);
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
    }
    ($('#hide')).hide();
    b.focus().slideDown(0);
    box_open = true;
    s.emit('open', {});
    return setTimeout((function() {
      return b.focus().val('');
    }), 1);
  });
  sync = false;
  s.on('open', function(t) {
    return render_post(t);
  });
  s.on('thread', function(t) {
    my_thread = t.thread;
    return sync = true;
  });
  b.bind('input', function() {
    if (sync) {
      t = {
        'text': b.val().slice(0, 37),
        'thread': my_thread
      };
      return s.emit('sync', t);
    }
  });
  s.on('sync', function(t) {
    var target;
    target = $(".thread" + t.thread);
    if (target) {
      return target.text(t.text);
    } else {
      return render_post(t);
    }
  });
  s.on('close', function(t) {
    sync = false;
    ($(".thread" + t.thread)).parent().attr('class', 'closed');
    if (t.text.length < 2) return ($(".thread" + t.thread)).parent().remove();
  });
  render_topic = function(t) {
    var post;
    post = "			<nav class='" + t.state + " " + t.topic + "'>				<nav class='thread" + t.thread + "'					style='						width: 500px;						height: 26px;						overflow: hidden;						'>				</nav>			</nav>";
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
    }
    return s.emit('create');
  });
  s.on('create', function(t) {
    ($('#hide')).hide();
    render_topic(t);
    b.focus().slideDown(1);
    setTimeout((function() {
      return b.focus().val('');
    }), 1);
    box_open = true;
    return ($("." + t.topic)).click(function() {
      var r;
      r = {
        'topic': t.topic
      };
      return s.emit('join', r);
    });
  });
  s.on('new topic', function(t) {
    var i, _i, _len, _ref, _results;
    last_name = '';
    ($('#thread')).empty();
    _ref = t.data;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      i = _ref[_i];
      _results.push(render_post(i));
    }
    return _results;
  });
  s.on('topic history', function(t) {
    var i, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = t.length; _i < _len; _i++) {
      i = t[_i];
      _results.push((function(i) {
        var post;
        post = "					<nav class='closed' id='" + i.topic + "'>						<nav class='thread" + i.thread + "'							style='							width: 500px;							height: 26px;							overflow: hidden;							'>							" + i.text + "						</nav>					</nav>";
        ($('#topic')).append(post);
        return ($("#" + i.topic)).click(function() {
          var r;
          r = {
            'topic': i.topic
          };
          return s.emit('join', r);
        });
      })(i));
    }
    return _results;
  });
  return s.emit('join', {
    'topic': 'topic0'
  });
});
