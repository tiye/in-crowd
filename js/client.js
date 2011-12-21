var id_num, render;

render = function(name, id, content, cls) {
  var c;
  c = '<div><nav class="name">';
  c += name;
  c += '&nbsp;</nav><nav class="';
  c += cls;
  c += '" id="';
  c += id;
  c += '">';
  c += content;
  c += '</nav></div>';
  return c;
};

id_num = 'none';

window.onload = function() {
  var socket, text_hide;
  var _this = this;
  ($('#text')).hide();
  socket = io.connect('http://zhongli.heroku.com');
  socket.emit('set nickname', prompt('<please input your name>'));
  text_hide = true;
  document.onkeypress = function(e) {
    if (e.keyCode === 13) {
      if (text_hide) {
        ($('#text')).show().focus().val('');
        text_hide = false;
        return socket.emit('open', '');
      } else {
        ($('#text')).hide().focus();
        text_hide = true;
        socket.emit('close', id_num);
        return id_num = 'none';
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
    return ($('#box')).append(render(data.name, data.id, '/joined/', 'done'));
  });
  socket.on('user_left', function(data) {
    return ($('#box')).append(render(data.name, data.id, '/left/', 'done'));
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
    ($('#box')).append(render(data.name, data.id, '', 'raw'));
    return $(window).scrollTop($(document).height());
  });
  socket.on('close', function(id_num) {
    var t, tm, tmp;
    ($('#' + id_num)).attr('class', 'done');
    t = new Date();
    tm = t.getDate() + '-' + t.getHours() + ':' + t.getMinutes() + ':' + t.getSeconds();
    tmp = ($('#' + id_num)).html() + '<span class="time">&nbsp;' + tm + '</span>';
    return ($('#' + id_num)).html(tmp);
  });
  return socket.on('sync', function(data) {
    return ($('#' + data.id)).html(data.content);
  });
};
