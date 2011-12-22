var id_num, last_name, render, try_scroll;

render = function(name, id, content, cls) {
  var c, t, tm;
  c = '<div><nav class="name">';
  c += name;
  c += '&nbsp;</nav><nav class="';
  c += cls;
  c += '" id="';
  c += id;
  c += '">';
  c += content + '<span class="time">';
  t = new Date();
  tm = t.getDate() + '-' + t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
  c += ' </span>' + tm;
  c += '</nav></div>';
  return c;
};

try_scroll = function() {
  if (($(window)).scrollTop() + ($(window)).height() + 10 > ($(document)).height()) {
    ($(window)).scrollTop(($(document)).height());
    return console.log('scrolled ');
  }
};

id_num = 'none';

last_name = '';

window.onload = function() {
  var socket, text_hide;
  var _this = this;
  ($('#text')).hide();
  socket = io.connect(window.location.hostname);
  socket.emit('set nickname', prompt('Please input your name:'));
  socket.on('unready', function() {
    return socket.emit('set nickname', prompt('Name used, pleas choose another one:'));
  });
  text_hide = true;
  document.onkeypress = function(e) {
    var content;
    if (e.keyCode === 13) {
      if (text_hide) {
        ($('#text')).show().focus().val('');
        text_hide = false;
        return socket.emit('open', '');
      } else {
        content = ($('#text')).val();
        ($('#text')).hide().focus();
        text_hide = true;
        socket.emit('close', id_num, content);
        return id_num = 'none';
      }
    } else {
      if (text_hide) {
        ($('#text')).show().focus().val('');
        text_hide = false;
        return socket.emit('open', '');
      }
    }
  };
  ($('#text')).bind('input', function(e) {
    var text_content;
    text_content = ($('#text')).val();
    return socket.emit('sync', {
      'id': id_num,
      'content': text_content
    });
  });
  socket.on('new_user', function(data) {
    ($('#box')).append(render(data.name, data.id, '/joined/', 'sys'));
    return try_scroll();
  });
  socket.on('user_left', function(data) {
    ($('#box')).append(render(data.name, data.id, '/left/', 'sys'));
    return try_scroll();
  });
  socket.on('open_self', function(data) {
    id_num = data.id;
    ($('#box')).append(render(data.name, data.id, '', 'raw'));
    setTimeout((function() {
      return ($('#text')).val('');
    }), 10);
    return try_scroll();
  });
  socket.on('open', function(data) {
    console.log('on open');
    ($('#box')).append(render(data.name, data.id, '', 'raw'));
    return try_scroll();
  });
  socket.on('close', function(id_num) {
    return ($('#' + id_num)).attr('class', 'done');
  });
  socket.on('sync', function(data) {
    var t, tm, tmp;
    t = new Date();
    tm = t.getDate() + '-' + t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
    tmp = '<span class="time">&nbsp;' + tm + '</span>';
    ($('#' + data.id)).text(data.content);
    ($('#' + data.id)).append(tmp);
    return try_scroll();
  });
  return socket.on('logss', function(logs) {
    var item, _i, _len;
    for (_i = 0, _len = logs.length; _i < _len; _i++) {
      item = logs[_i];
      if (item[0] === last_name) {
        item[0] = '&nbsp;';
      } else {
        last_name = item[0];
      }
      ($('#box')).append(render(item[0], 'raw', item[1], 'raw'));
    }
    return try_scroll();
  });
};
