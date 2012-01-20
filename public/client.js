
$(function() {
  var b, box_open, chat_page, login_page, logined, my_thread, render_post, s, t;
  s = io.connect(window.location.hostname);
  logined = false;
  my_thread = 0;
  chat_page = function(t) {
    ($('#login')).slideUp(100);
    ($('#about')).slideUp(200);
    ($('#board')).slideDown(200);
    $.cookie('name', t.name);
    return logined = true;
  };
  login_page = function() {
    var bind_login;
    ($('#board')).slideUp(200);
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
    post = "<nav class='" + t.state + "'				style='					width: 600px;					height: 26px;					display: -moz-box;					display: -webkit-box;					-moz-box-orient: horizontal;					-webkit-box-orient: horizontal;					'>				<nav id='thread" + t.thread + "'					style='						width: 500px;						height: 26px;						overflow: hidden;						background: hsl(40,80%,80%);						'>				</nav>				<nav class='name'					style='						width: 100px;						height: 26px;						overflow: hidden;						background: hsl(300,80%,80%);						'>					" + t.name + "				</nav>			</nav>";
    return ($('#thread')).append(post);
  };
  ($(document)).keydown(function(e) {
    if (e.keyCode === 13 && logined) {
      if (box_open) {
        b.focus().slideUp(100);
        box_open = false;
        t = {
          'thread': my_thread
        };
        return s.emit('close', t);
      } else {
        b.focus().slideDown(100);
        box_open = true;
        s.emit('open', {});
        my_thread = 0;
        return setTimeout((function() {
          return b.val('');
        }), 1);
      }
    }
  });
  s.on('open', function(t) {
    return render_post(t);
  });
  s.on('thread', function(t) {
    return my_thread = t.thread;
  });
  b.bind('input', function() {
    t = {
      'text': b.val(),
      'thread': my_thread
    };
    return s.emit('sync', t);
  });
  s.on('sync', function(t) {
    console.log('suny');
    return ($("#thread" + t.thread)).text(t.text);
  });
  return s.on('close', function(t) {
    return ($("#thread" + t.thread)).parent().attr('class', 'closed');
  });
});
