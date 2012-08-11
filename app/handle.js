var clock, format2, found, key_add, key_down, key_enter, key_esc, key_left, key_pgdown, key_pgup, key_right, key_up, login_url, ls, mark, post_box, s, show, sight, slide_left, slide_tag,
  __slice = Array.prototype.slice;

key_pgup = 33;

key_pgdown = 34;

key_up = 38;

key_down = 40;

key_left = 37;

key_right = 39;

key_esc = 27;

key_enter = 13;

key_add = 65;

mark = function() {
  return String(new Date().getTime());
};

format2 = function(num) {
  if (num < 10) {
    return '0' + (String(num));
  } else {
    return String(num);
  }
};

clock = function() {
  var date, hour, minute, month, now;
  now = new Date();
  month = format2(now.getMonth() + 1);
  date = format2(now.getDate());
  hour = format2(now.getHours());
  minute = format2(now.getMinutes());
  return {
    date: "" + month + "/" + date,
    time: "" + hour + ":" + minute
  };
};

show = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return console.log.apply(console, args);
};

found = function(elems) {
  return elems.length > 0;
};

login_url = 'https://github.com/login/oauth/authorize' + '?client_id=1b9a3afb748a45643c8d';

post_box = function(data) {
  var id, t, time;
  if (data.reply != null) data.reply = String(data.reply);
  if (data.time) {
    time = data.time;
  } else {
    time = clock();
  }
  t = "" + (time.date || '') + " " + (time.time || '');
  id = data.cid != null ? "cid_" + data.cid : data.tid != null ? "tid_" + data.tid : '';
  return "<div class=\"unit\" id=\"" + id + "\">\n  <header class=\"icon\">\n    <img class=\"icon\" src=\"" + data.avatar_url + "\"/>\n  </header>\n  <div class=\"detail\">\n    <p class=\"info\">\n      <span class=\"nick\"> " + (data.nick || '') + " </span>\n      <span class=\"name\"> " + (data.login || '') + " </span>\n      <span class=\"reply\"> " + (data.reply || '') + " </span>\n      <span class=\"time\"> " + t + " </span>\n    </p>\n    <p class=\"value " + (data.input || '') + "\">\n      " + (data.value || '') + "\n    </p>\n  </div>\n</div>";
};

ls = localStorage;

sight = void 0;

slide_tag = function(value) {
  if (value != null) {
    return ls.sight = value;
  } else {
    return ls.sight;
  }
};

slide_left = function(next) {
  var left;
  left = next.offset().left - 20;
  return $('body').animate({
    scrollLeft: left
  }, function() {
    sight = next;
    return slide_tag(sight.attr('id'));
  });
};

s = io.connect('http://localhost:8002');

s.on('err', function(err) {
  return show('API ERROR: ', err);
});

addEventListener('message', function(child) {
  var token;
  token = child.data.match(/code=([0-9a-f]+)/)[1];
  return s.emit('token', token);
});

s.on('stemp', function(stemp) {
  if (ls.server_stemp != null) {
    if (ls.server_stemp !== stemp) {
      ls.server_stemp = stemp;
      return location.reload();
    }
  } else {
    return ls.server_stemp = stemp;
  }
});

s.on('key', function(key) {
  return ls.key = key;
});

if (ls.authed != null) s.emit('key', ls.key);

$(function() {
  var add_topic, body, finish_chat, finish_topic, login_link, logio, logout_link, next, preview, render_login, see_chat, set_chat, start_chat, start_topic, tag;
  body = $('body');
  if (slide_tag() != null) {
    tag = slide_tag();
    next = $("#" + tag);
    slide_left(next);
  } else {
    sight = $('body').children().first();
  }
  body.keydown(function(e) {
    show(e.keyCode);
    switch (e.keyCode) {
      case key_pgup:
        if (found(sight.prev())) slide_left(sight.prev());
        break;
      case key_pgdown:
        if (found(sight.next())) slide_left(sight.next());
        break;
      case key_up:
        show('key_up');
        break;
      case key_down:
        show('key_down');
    }
    if (ls.authed != null) {
      switch (e.keyCode) {
        case key_enter:
          if (ls.sight === 'topic') {
            if (found($('#topic input'))) {
              return finish_topic();
            } else {
              return start_topic();
            }
          } else if (ls.sight === 'chat') {
            if (found($('#chat input'))) {
              return finish_chat();
            } else {
              return start_chat();
            }
          }
      }
    }
  });
  start_topic = function() {
    $('#topic').append('<input class="input"/>');
    return $('#topic input').focus().hide().slideDown();
  };
  finish_topic = function() {
    var input, tid, value;
    input = $("#topic input");
    value = input.val().trim();
    tid = "" + ls.login + "_" + (mark());
    if (value.length > 0) s.emit('add_topic', value, tid, clock());
    return input.slideUp(function() {
      return input.remove();
    });
  };
  start_chat = function() {
    var input;
    $('#chat').append('<input class="input"/>');
    ls.cid = "" + ls.login + "_" + (mark());
    input = $('#chat input').focus();
    return input.bind('input', function() {
      return s.emit('chat', ls.tid, ls.cid, input.val().trim(), clock(), false);
    });
  };
  finish_chat = function() {
    var input, value;
    input = $("#chat input");
    value = input.val().trim();
    s.emit('end_chat', ls.tid, ls.cid, value, clock(), true);
    return input.slideUp(function() {
      return input.remove();
    });
  };
  login_link = function() {
    return open(login_url);
  };
  logout_link = function() {
    s.emit('logout');
    preview('404', '.guest');
    logio.unbind('click', logout_link);
    logio.click(login_link);
    ls.removeItem('authed');
    ls.removeItem('key');
    return logio.text('click to login');
  };
  logio = $('#config .login span');
  logio.click(login_link);
  preview = function(avatar_url, login) {
    $('#config img').attr('src', avatar_url);
    return $('#config .unit .name').text(login);
  };
  render_login = function(data) {
    preview(data.avatar_url, data.login);
    if (data.nick != null) {
      $('#config .nick').text(data.nick);
      $('#nick').val(data.nick);
      ls.nick = nick;
    }
    if (data.value != null) {
      $('#config .value').text(data.value);
      $('#value').val(data.value);
      ls.value = data.value;
    }
    logio.unbind('click', login_link);
    logio.click(logout_link);
    logio.text('logout');
    ls.authed = 'yes';
    ls.login = data.login;
    return ls.avatar_url = data.avatar_url;
  };
  s.on('login', render_login);
  $('#nick').blur(function() {
    var get_nick;
    get_nick = $('#nick').val().slice(0, 21);
    $('#config .unit .nick').text(get_nick);
    s.emit('nick', get_nick);
    return ls.nick = nick;
  });
  $('#value').blur(function() {
    var get_value;
    get_value = $('#value').val().slice(0, 21);
    $('#config .unit .value').text(get_value);
    s.emit('value', get_value);
    return ls.value = ls.value;
  });
  add_topic = function(data) {
    var box, elem;
    box = post_box(data);
    $('#topic').append(box);
    elem = $('#topic').children().last();
    elem.hide().slideDown();
    return elem.click(function() {
      return see_chat(data.tid);
    });
  };
  set_chat = function(data) {
    var box, cid, hide, scope, target, tid;
    tid = data.tid;
    cid = data.cid;
    scope = $("#chat #scope_" + tid);
    if (!found(scope)) {
      if (found($('#chat>div:visible'))) hide = true;
      $("#chat").append("<div id='scope_" + tid + "'/>");
      scope = $("#chat #scope_" + tid);
      if (hide) scope.hide();
    }
    target = scope.find("#cid_" + cid);
    if (found(target)) {
      $("#chat #cid_" + cid).find('.value').text(data.value);
    } else {
      box = post_box(data);
      scope.append(box);
      target = scope.find("#cid_" + cid);
      target.hide().slideDown();
    }
    if (data.value.length === 0) {
      return target.slideUp(function() {
        return target.remove();
      });
    }
  };
  see_chat = function(tid) {
    var elem;
    $('#chat>div:visible').hide();
    $("#chat #scope_" + tid).slideDown();
    ls.tid = tid;
    s.emit('topic', tid);
    elem = $('#topic .curr');
    if (found(elem)) elem.removeClass('curr');
    return $("#topic #tid_" + tid).addClass('curr');
  };
  s.on('add_topic', add_topic);
  s.on('start_page', function(list) {
    var tid;
    list.forEach(add_topic);
    tid = $('#topic').children().last().attr('id').slice(4);
    return see_chat(tid);
  });
  s.on('topic', function(list) {
    show(list);
    return list.forEach(set_chat);
  });
  s.on('chat', function(data) {
    return set_chat(data);
  });
  return s.on('end_chat', function(data) {
    return set_chat(data);
  });
});
