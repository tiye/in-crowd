var get_name, id_num, last_name, render, try_scroll;

last_name = '';

id_num = '';

render = function(name, id, content, cls, time, room) {
  var c;
  if (name === last_name) {
    name = '';
  } else {
    last_name = name;
  }
  c = '<div><nav class="name">';
  c += name;
  c += '&nbsp;</nav><nav class="';
  c += cls;
  c += '" id="';
  c += id;
  c += '">';
  c += content + '<span class="time">' + time + '@' + room;
  c += ' </span>';
  c += '</nav></div>';
  ($('#box')).append(c);
  return try_scroll();
};

try_scroll = function() {
  if (($('#box')).scrollTop() + ($('#box')).height() + 200 > ($('#box'))[0].scrollHeight) {
    return ($('#box')).scrollTop(($('#box'))[0].scrollHeight);
  }
};

get_name = function(strns) {
  var a;
  a = '';
  while (!(a.length > 0 && a.length < 10)) {
    a = prompt(strns);
  }
  document.cookie = 'zhongli_name=' + (encodeURI(a));
  return a;
};

window.onload = function() {
  var arr, room_arr, socket, text_hide;
  ($('#text')).hide();
  socket = io.connect(window.location.hostname);
  room_arr = document.cookie.match(/zhongli_room=([^;]*)(;|$)/);
  if (room_arr) {
    socket.emit('room0', decodeURI(room_arr[1]));
  } else {
    socket.emit('room0', '0');
  }
  arr = document.cookie.match(/zhongli_name=([^;]*)(;|$)/);
  if (arr) {
    socket.emit('set nickname', decodeURI(arr[1]));
  } else {
    socket.emit('set nickname', get_name('输入一个长度合适的名字'));
  }
  socket.emit('who');
  socket.on('unready', function() {
    return socket.emit('set nickname', get_name('看来需要换个名字'));
  });
  text_hide = true;
  document.onkeypress = function(e) {
    var cmd, content, matching;
    if (e.keyCode === 13) {
      if (text_hide) {
        ($('#text')).slideDown(200).focus().val('');
        text_hide = false;
        return socket.emit('open', '');
      } else {
        if (($('#text')).val()[0] === '/') {
          cmd = ($('#text')).val();
          switch (cmd) {
            case '/who':
              socket.emit('who');
              break;
            case '/clear':
              ($('#box')).empty();
              last_name = '';
              break;
            case '/forget':
              document.cookie = 'zhongli_name=tolongtoberemmembered!!!';
              break;
            case '/history':
              socket.emit('history');
              break;
            case '/where':
              socket.emit('where');
              break;
            case '/groups':
              socket.emit('groups');
          }
        }
        if (matching = ($('#text')).val().match(/\/join (\S+)/)) {
          socket.emit('join', matching[1]);
        }
        if (($('#text')).val().length > 0) {
          content = ($('#text')).val();
          ($('#text')).slideUp(200).focus().val();
          text_hide = true;
          socket.emit('close', id_num, content);
          return id_num = '';
        } else {
          console.log('send to pass');
          socket.emit('pass', id_num);
          ($('#text')).slideUp(200).focus().val('');
          return text_hide = true;
        }
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
    render(data.name, data.id, '::进入了群组: ' + data.room + ' @', 'sys', data.time, data.room);
    return document.cookie = 'zhongli_room=' + (encodeURI(data.room));
  });
  socket.on('user_left', function(data) {
    return render(data.name, data.id, '::离开了群组: ' + data.room + ' @', 'sys', data.time, data.room);
  });
  socket.on('open', function(data) {
    return render(data.name, data.id, '', 'raw', data.time, data.room);
  });
  socket.on('change_id', function(new_id) {
    return id_num = new_id;
  });
  socket.on('close', function(id_num) {
    return ($('#' + id_num)).attr('class', 'done');
  });
  socket.on('sync', function(data) {
    var tmp;
    if ($('#' + data.id)) {
      tmp = '<span class="time">&nbsp;' + data.time + '@' + data.room + '</span>';
      ($('#' + data.id)).text(data.content);
      return ($('#' + data.id)).append(tmp);
    } else {
      return render(data.name, data.id, data.content, 'raw', data.time);
    }
  });
  socket.on('logs', function(logs) {
    var item, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = logs.length; _i < _len; _i++) {
      item = logs[_i];
      _results.push(render(item[0], 'sys', item[1], 'raw', item[2], item[3]));
    }
    return _results;
  });
  socket.on('who', function(msg, time) {
    var i, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = msg.length; _i < _len; _i++) {
      i = msg[_i];
      _results.push(render('/who', 'sys', i, 'sys', time, ''));
    }
    return _results;
  });
  socket.on('history', function(logs) {
    var item, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = logs.length; _i < _len; _i++) {
      item = logs[_i];
      _results.push(render(item[0], 'sys', item[1], 'sys', item[2], item[3]));
    }
    return _results;
  });
  socket.on('where', function(room_name, time) {
    return render('/where', 'sys', '::正在' + room_name + '群@', 'sys', time, '');
  });
  socket.on('groups', function(names, data, time) {
    var item, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = names.length; _i < _len; _i++) {
      item = names[_i];
      _results.push(render('/groups', 'sys', '::群名' + item + '::人数' + data[item] + '@', 'sys', time, ''));
    }
    return _results;
  });
  return socket.on('pass', function(pass_id) {
    ($('#' + pass_id)).parent().remove();
    return console.log('received');
  });
};
