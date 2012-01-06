var main, render_groups, render_login_page, render_nickname_page, render_post, socket, text_box_off, try_scroll;

text_box_off = true;

socket = io.connect(window.location.hostname);

main = function() {
  var my_thread;
  render_login_page();
  ($('#post')).hide();
  my_thread = null;
  document.onkeypress = function(e) {
    if (e.keyCode === 13) {
      if (text_box_off) {
        ($('#post')).show().focus();
        text_box_off = false;
        socket.emit('open post');
        return setTimeout((function() {
          return ($('#post')).val('');
        }), 2);
      } else {
        socket.emit('close post', my_thread, ($('#post')).val());
        text_box_off = true;
        return ($('#post')).hide().focus();
      }
    }
  };
  ($('#post')).bind('input', function(e) {
    var post_content;
    post_content = ($('#post')).val();
    return socket.emit('sync', my_thread, ($('#post')).val());
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
  socket.on('list groups', function(groups_data) {
    console.log('got msg to list groups');
    return render_groups(groups_data);
  });
  return socket.on('already logout', function() {
    return render_login_page();
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

render_post = function(thread_id, timestamp, username) {
  var render_content;
  render_content = "<nav id='post_id" + thread_id + "' class='posted_box'>";
  render_content += "<nav class='posted_content_raw'> @ " + timestamp + "</nav>";
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

render_groups = function(groups_data) {
  ($('#left')).empty();
  ($('#left')).append("<nav>jiyinyiyong, time<br/>hi my google</nav>");
  ($('#left')).append("<nav id='logout'>click to logout</nav>");
  return ($('#logout')).click(function() {
    navigator.id.logout();
    return socket.emit('logout');
  });
};

window.onload = main;
