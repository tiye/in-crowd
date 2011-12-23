var id_num, last_name, render, try_scroll;

render = function(name, id, content, cls, time) {
  var c;
  c = '<div><nav class="name">';
  c += name;
  c += '&nbsp;</nav><nav class="';
  c += cls;
  c += '" id="';
  c += id;
  c += '">';
  c += content + '<span class="time">' + time;
  c += ' </span>';
  c += '</nav></div>';
  ($('#box')).append(c);
  try_scroll();
  return this;
};

try_scroll = function() {
  if (($('#box')).scrollTop() + ($('#box')).height() + 200 > ($('#box'))[0].scrollHeight) {
    ($('#box')).scrollTop(($('#box'))[0].scrollHeight);
  }
  return this;
};

id_num = 'none';

last_name = '';

window.onload = function() {
  var socket, text_hide;
  ($('#text')).hide();
  socket = io.connect(window.location.hostname);
  socket.emit('set nickname', prompt('Please input your name:'));
  socket.emit('who');
  socket.on('unready', function() {
    socket.emit('set nickname', prompt('Name used, another one:'));
    return this;
  });
  text_hide = true;
  document.onkeypress = function(e) {
    var content;
    if (e.keyCode === 13) {
      if (text_hide) {
        ($('#text')).slideDown(200).focus().val('');
        text_hide = false;
        socket.emit('open', '');
      } else {
        if (($('#text')).val()[0] === '/') {
          switch (($('#text')).val()) {
            case '/who':
              socket.emit('who');
              break;
            case '/clear':
              console.log('do');
              ($('#box')).empty();
          }
        }
        if (($('#text')).val().length > 2) {
          content = ($('#text')).val();
          ($('#text')).slideUp(200).focus();
          text_hide = true;
          socket.emit('close', id_num, content);
          id_num = 'none';
        } else {
          ($('#text')).val('');
        }
      }
    }
    return this;
  };
  ($('#text')).bind('input', function(e) {
    var t, text_content;
    t = $('#text');
    if (t.val()[0] === '\n') t.val(t.val().slice(1));
    text_content = t.val().slice(0, 60);
    socket.emit('sync', {
      'id': id_num,
      'content': text_content
    });
    return this;
  });
  ($('#text')).bind('paste', function() {
    alert('coped this string of code, do not paste');
    return this;
  });
  socket.on('new_user', function(data) {
    render(data.name, data.id, '/joined/', 'sys', data.time);
    return this;
  });
  socket.on('user_left', function(data) {
    render(data.name, data.id, '/left/', 'sys', data.time);
    return this;
  });
  socket.on('open_self', function(data) {
    id_num = data.id;
    render(data.name, data.id, '', 'raw', data.time);
    ($('#text')).val('');
    return this;
  });
  socket.on('open', function(data) {
    render(data.name, data.id, '', 'raw', data.time);
    return this;
  });
  socket.on('close', function(id_num) {
    ($('#' + id_num)).attr('class', 'done');
    return this;
  });
  socket.on('sync', function(data) {
    var tmp;
    tmp = '<span class="time">&nbsp;' + data.time + '</span>';
    ($('#' + data.id)).text(data.content);
    ($('#' + data.id)).append(tmp);
    return this;
  });
  socket.on('logs', function(logs) {
    var item, _i, _len, _ref;
    _ref = logs.slice(-5);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      if (item[0] === last_name) {
        item[0] = '&nbsp;';
      } else {
        last_name = item[0];
      }
      render(item[0], 'raw', item[1], 'raw', item[2]);
    }
    return this;
  });
  socket.on('who', function(msg, time) {
    return render('/who', 'raw', msg, 'raw', time);
  });
  return this;
};
