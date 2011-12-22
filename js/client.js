var id_num, render;

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

id_num = 'none';

window.onload = function() {
  var socket, text_hide;
  var _this = this;
  ($('#text')).hide();
  socket = io.connect(window.location.hostname);
  socket.emit('logs');
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
    return ($('#box')).append(render(data.name, data.id, '/joined/', 'sys'));
  });
  socket.on('user_left', function(data) {
    return ($('#box')).append(render(data.name, data.id, '/left/', 'sys'));
  });
  socket.on('open_self', function(data) {
    id_num = data.id;
    ($('#box')).append(render(data.name, data.id, '', 'raw'));
    $(window).scrollTop($(document).height());
    setTimeout((function() {
      return ($('#text')).val('');
    }), 10);
    return $(window).scrollTop($(document).height());
  });
  socket.on('open', function(data) {
    console.log('on open');
    ($('#box')).append(render(data.name, data.id, '', 'raw'));
    return $(window).scrollTop($(document).height());
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
  return socket.on('loging', function(logs) {
    var item, _i, _len, _results;
    console.log('got: ', logs);
    _results = [];
    for (_i = 0, _len = logs.length; _i < _len; _i++) {
      item = logs[_i];
      console.log(item);
      _results.push(($('#box')).append(render(item[0], 'raw', item[1], 'raw')));
    }
    return _results;
  });
};
