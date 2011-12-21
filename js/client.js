var render;

render = function(name, id, content, cls) {
  var c;
  c = '<div><span class="name">';
  c += name;
  c += ':</span><span class="';
  c += cls;
  c += '" id="';
  c += id;
  c += '">';
  c += content;
  c += '</span></div>';
  return c;
};

window.onload = function() {
  var id_num, socket, text_hide;
  var _this = this;
  ($('#text')).hide();
  socket = io.connect('http://localhost');
  socket.emit('set nickname', prompt('<please input your name>'));
  text_hide = true;
  id_num = 'id';
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
        return id_num = 'id';
      }
    }
  };
  $('#text').keydown(function() {
    return setTimeout((function() {
      var text_content;
      text_content = ($('#text')).val();
      return socket.emit('sync', {
        'id': id_num,
        'content': text_content
      });
    }), 20);
  });
  socket.on('new_user', function(data) {
    return ($('#box')).append(render(data.name, data.id, '/joined/', 'done'));
  });
  socket.on('user_left', function(data) {
    return ($('#box')).append(render(data.name, data.id, '/left/', 'done'));
  });
  socket.on('open', function(data) {
    id_num = data.id;
    return ($('#box')).append(render(data.name, data.id, '', 'raw'));
  });
  socket.on('close', function(id_num) {
    return ($('#' + id_num)).attr('class', 'done');
  });
  return socket.on('sync', function(data) {
    console.log(data);
    return ($('#' + data.id)).html(data.content);
  });
};
