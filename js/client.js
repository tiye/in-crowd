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
  if (($('#box')).scrollTop() + ($('#box')).height() + 200 > ($('#box'))[0].scrollHeight) {
    return ($('#box')).scrollTop(($('#box'))[0].scrollHeight);
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
    var content, key;
    key = e.keyCode;
    if (key === 13) {
      if (text_hide) {
        ($('#text')).slideDown(200).focus().val('');
        text_hide = false;
        return socket.emit('open', '');
      } else {
        if (($('#text')).val().length > 2) {
          content = ($('#text')).val();
          ($('#text')).slideUp(200).focus();
          text_hide = true;
          socket.emit('close', id_num, content);
          return id_num = 'none';
        } else {
          return ($('#text')).val('');
        }
      }
    } else {
      if (key >= 48 && key <= 90) {
        ($('#text')).slideDown(200).focus().val('');
        text_hide = false;
        return socket.emit('open', '');
      }
    }
  };
  ($('#text')).bind('input', function(e) {
    var t, text_content;
    t = $('#text');
    if (t.val()[0] === '\n') t.val(t.val().slice(1));
    text_content = t.val().slice(0, 60);
    return socket.emit('sync', {
      'id': id_num,
      'content': text_content
    });
  });
  ($('#text')).bind('paste', function() {
    return alert('coped this string of code, do not paste');
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
    ($('#text')).val('');
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
    return ($('#' + data.id)).append(tmp);
  });
  return socket.on('logss', function(logs) {
    var item, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = logs.length; _i < _len; _i++) {
      item = logs[_i];
      if (item[0] === last_name) {
        item[0] = '&nbsp;';
      } else {
        last_name = item[0];
      }
      ($('#box')).append(render(item[0], 'raw', item[1], 'raw'));
      _results.push(try_scroll());
    }
    return _results;
  });
};
