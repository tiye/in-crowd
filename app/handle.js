var clock, format2, found, key_add, key_down, key_enter, key_esc, key_left, key_pgdown, key_pgup, key_right, key_up, login_url, ls, mark, s, show, sight, slide_left, slide_tag,
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
  var body, login_link, logio, logout_link, next, post_box, preview, render_login, tag, toggle_topic;
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
            return toggle_topic();
          } else if (ls.sight === 'chat') {
            return toggle_chat();
          }
      }
    }
  });
  post_box = function(data) {
    var me, other, t, time;
    if (data.reply != null) data.reply = String(data.reply);
    if (data.time) {
      time = data.time;
    } else {
      time = clock();
    }
    t = "" + (time.date || '') + " " + (time.time || '');
    me = "<input class=\"state\"></input>";
    other = "<p class=\"state\" id=\"" + (data.topic_id || '') + "\">\n" + (data.state || '') + "</p>";
    return "<div class=\"unit\">\n  <header class=\"icon\">\n    <img class=\"icon\" src=\"" + data.avatar_url + "\"/>\n  </header>\n  <div class=\"detail\">\n    <p class=\"info\">\n      <span class=\"nick\">\n        " + (data.nick || '') + "\n      </span>\n      <span class=\"name\">\n        " + (data.login || '') + "\n      </span>\n      <span class=\"reply\">\n        " + (data.reply || '') + "\n      </span>\n      <span class=\"time\">\n        " + t + "\n      </spam>\n    </p>\n    " + (data.nick === '.me' ? me : other) + "\n  </div>\n</div>";
  };
  toggle_topic = function() {
    var box, elem, input, parent, tmp, value;
    if (found($("#topic input"))) {
      elem = $("#topic input");
      value = elem.val().trim();
      if (value.length === 0) {
        parent = elem.parent().parent();
        return parent.slideUp(function() {
          return parent.remove();
        });
      } else {
        elem[0].outerHTML = "<div class='state'>" + value + "</div>";
        return s.emit('add_topic', value, ls.topic_id, clock());
      }
    } else {
      box = post_box({
        avatar_url: ls.avatar_url,
        nick: '.me',
        reply: 0
      });
      $("#topic").append(box).children().last().hide().slideDown();
      input = $("#topic input").focus();
      tmp = ls.topic_id = "" + ls.login + "_" + (mark());
      return input.parent().click(function() {
        return s.emit('topic', tmp);
      });
    }
  };
  login_link = function() {
    return open(login_url);
  };
  logout_link = function() {
    s.emit('logout');
    preview('?', '?');
    logio.unbind('click', logout_link);
    logio.click(login_link);
    ls.removeItem('authed');
    ls.removeItem('key');
    return logio.text('click to login');
  };
  logio = $('#config .login span');
  logio.click(login_link);
  s.on('err', function(err) {
    return show(err);
  });
  preview = function(avatar_url, login) {
    $('#config img').attr('src', avatar_url);
    return $('#config .unit .name').text(login);
  };
  render_login = function(data) {
    preview(data.avatar_url, data.login);
    if (data.nick != null) {
      $('#config .nick').text(data.nick);
      $('#nick').val(data.nick);
    }
    if (data.state != null) {
      $('#config .state').text(data.state);
      $('#state').val(data.state);
    }
    logio.unbind('click', login_link);
    logio.click(logout_link);
    ls.authed = 'yes';
    ls.login = data.login;
    logio.text('logout');
    return ls.avatar_url = data.avatar_url;
  };
  s.on('login', render_login);
  $('#nick').blur(function() {
    var get_nick;
    get_nick = $('#nick').val().slice(0, 21);
    $('#config .unit .nick').text(get_nick);
    return s.emit('nick', get_nick);
  });
  $('#state').blur(function() {
    var get_state;
    get_state = $('#state').val().slice(0, 21);
    $('#config .unit .state').text(get_state);
    return s.emit('state', get_state);
  });
  s.on('add_topic', function(data) {
    var box, elem;
    box = post_box(data);
    elem = $("#topic").append(box).children().last();
    return elem.hide().slideDown(function() {
      return $("#" + data.topic_id).parent().click(function() {
        return s.emit('topic', data.topic_id);
      });
    });
  });
  return s.on('start_page', function(list) {
    return list.forEach(function(data) {
      var box, elem;
      box = post_box(data);
      elem = $("#topic").append(box).children().last();
      return elem.hide().slideDown(function() {
        return $("#" + data.topic_id).parent().click(function() {
          return s.emit('topic', data.topic_id);
        });
      });
    });
  });
});
