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
  socket.on('unready', function() {
    socket.emit('set nickname', prompt('Name used, pleas choose another one:'));
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
    ($('#box')).append(render(data.name, data.id, '/joined/', 'sys'));
    try_scroll();
    return this;
  });
  socket.on('user_left', function(data) {
    ($('#box')).append(render(data.name, data.id, '/left/', 'sys'));
    try_scroll();
    return this;
  });
  socket.on('open_self', function(data) {
    id_num = data.id;
    ($('#box')).append(render(data.name, data.id, '', 'raw'));
    ($('#text')).val('');
    try_scroll();
    return this;
  });
  socket.on('open', function(data) {
    console.log('on open');
    ($('#box')).append(render(data.name, data.id, '', 'raw'));
    try_scroll();
    return this;
  });
  socket.on('close', function(id_num) {
    ($('#' + id_num)).attr('class', 'done');
    return this;
  });
  socket.on('sync', function(data) {
    var t, tm, tmp;
    t = new Date();
    tm = t.getDate() + '-' + t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
    tmp = '<span class="time">&nbsp;' + tm + '</span>';
    ($('#' + data.id)).text(data.content);
    ($('#' + data.id)).append(tmp);
    return this;
  });
  socket.on('logss', function(logs) {
    var item, _i, _len;
    for (_i = 0, _len = logs.length; _i < _len; _i++) {
      item = logs[_i];
      if (item[0] === last_name) {
        item[0] = '&nbsp;';
      } else {
        last_name = item[0];
      }
      ($('#box')).append(render(item[0], 'raw', item[1], 'raw'));
      try_scroll();
    }
    return this;
  });
  return this;
};
