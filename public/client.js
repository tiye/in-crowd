var main, o, render_groups, render_login_page, render_nickname_page, render_post, socket, text_box_off, try_scroll;

o = console.log;

text_box_off = true;

socket = io.connect(window.location.hostname);

main = function() {
  var my_thread;
  render_login_page();
  ($('#post')).hide().focus();
  my_thread = null;
  document.onkeypress = function(e) {
    if (e.keyCode === 13) {
      if (text_box_off) {
        ($('#post')).show();
        document.getElementById('post').focus();
        text_box_off = false;
        socket.emit('open post');
        return setTimeout((function() {
          return ($('#post')).val('');
        }), 2);
      } else {
        socket.emit('close post', my_thread, ($('#post')).val());
        text_box_off = true;
        return ($('#post')).hide();
      }
    }
  };
  ($('#post')).bind('input', function(e) {
    var post_content;
    post_content = ($('#post')).val();
    if (post_content.length > 0) {
      socket.emit('sync', my_thread, ($('#post')).val());
    }
    if (post_content.length > 30) {
      return ($('#post')).val(post_content.slice(0, 30));
    }
  });
  socket.on('open post', function(thread_id, timestamp, username) {
    my_thread = thread_id;
    render_post(thread_id, timestamp, username);
    return try_scroll();
  });
  socket.on('close post', function(id_num, post_content) {
    console.log(($('#post_id' + my_thread)).children().first().text());
    if (post_content === '') {
      return ($('#post_id' + my_thread)).remove();
    } else {
      return ($('#post_id' + my_thread)).children().first().attr('class', 'posted_content');
    }
  });
  socket.on('sync', function(sync_id, sync_data, timestamp, username) {
    var elem;
    if ($('#post_id' + sync_id)) {
      elem = ($('#post_id' + sync_id)).children().first();
      elem.text(sync_data);
      return elem.append("<span class='time'> @ " + timestamp + "</span>");
    }
  });
  socket.on('list groups', function(topics) {
    console.log('got msg to list groups');
    return render_groups(topics);
  });
  socket.on('already logout', function(post_data) {
    var item, _i, _len, _results;
    render_login_page();
    ($('#right')).empty();
    _results = [];
    for (_i = 0, _len = post_data.length; _i < _len; _i++) {
      item = post_data[_i];
      _results.push(render_post(item[1], item[3], item[4], item[2]));
    }
    return _results;
  });
  socket.on('add title', function(title_data, topic_id) {
    ($('#left')).append("<nav id='topic_id" + topic_id + "'>" + title_data + "</nav>");
    return ($("#topic_id" + topic_id)).click(function() {
      return socket.emit('join', "topic_id" + topic_id);
    });
  });
  socket.on('join', function(post_data) {
    var item, _i, _len, _results;
    ($('#right')).empty();
    _results = [];
    for (_i = 0, _len = post_data.length; _i < _len; _i++) {
      item = post_data[_i];
      _results.push(render_post(item[1], item[3], item[4], item[2]));
    }
    return _results;
  });
  socket.emit('begin');
  return socket.on('render begin', function(post_data) {
    var item, _i, _len, _results;
    ($('#right')).empty();
    _results = [];
    for (_i = 0, _len = post_data.length; _i < _len; _i++) {
      item = post_data[_i];
      _results.push(render_post(item[1], item[3], item[4], item[2]));
    }
    return _results;
  });
};

render_login_page = function() {
  var render_content;
  ($('#left')).empty();
  render_content = '<image src="https://browserid.org/i/sign_in_red.png" id="login_image"/>';
  ($('#left')).append(render_content);
  return ($('#login_image')).click(function() {
    return navigator.id.get((function(assersion) {
      socket.emit('login', assersion);
      return console.log('sending');
    }), {
      allowPersistent: true
    });
  });
};

render_nickname_page = function(arg) {
  var render_content;
  ($('#left')).empty();
  render_content = '<nav id="login_nickname"><textarea id="text_nickname">';
  render_content += '</textarea><button id="send_nickname">send</button>';
  if (arg) render_content += "<br/>" + arg;
  login_page_content += '</nav>';
  return ($('#left')).append(login_page_content);
};

render_post = function(thread_id, timestamp, username, content) {
  var render_content;
  if (content == null) content = '';
  render_content = "<nav id='post_id" + thread_id + "' class='posted_box'>";
  render_content += "<nav class='posted_content_raw'>" + content + " @ " + timestamp + "</nav>";
  render_content += "<nav class='posted_username'>" + username + "</nav></nav>";
  ($('#right')).append(render_content);
  return try_scroll();
};

try_scroll = function() {
  if (text_box_off) {
    if (($('#right')).scrollTop() + ($('#right')).height() + 200 > ($('#right'))[0].scrollHeight) {
      return ($('#right')).scrollTop(($('#right'))[0].scrollHeight);
    }
  }
};

render_groups = function(topics) {
  var item, _i, _len, _results;
  ($('#left')).empty();
  ($('#left')).append("<nav id='topic_id00'>Name, Time<br/>Content_of_posts</nav>");
  ($('#topic_id00')).click(function() {
    return socket.emit('join', "topic_id00");
  });
  ($('#left')).append("<nav id='logout'>click to logout</nav>");
  ($('#left')).append("<nav><textarea id='add_title'></textarea><br/><button id='send_title'>send</button></nav>");
  ($('#send_title')).click(function() {
    socket.emit('add title', ($('#add_title')).val());
    return ($('#add_title')).val('');
  });
  ($('#logout')).click(function() {
    navigator.id.logout();
    return socket.emit('logout');
  });
  _results = [];
  for (_i = 0, _len = topics.length; _i < _len; _i++) {
    item = topics[_i];
    ($('#left')).append("<nav id='topic_id" + item[0] + "'>" + item[1] + ", " + item[2] + "<br/>" + item[3] + "</nav>");
    _results.push(($("#topic_id" + item[0])).click(function() {
      return socket.emit('join', "topic_id" + item[0]);
    }));
  }
  return _results;
};

window.onload = main;
