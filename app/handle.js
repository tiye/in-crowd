var found, key_add, key_down, key_enter, key_esc, key_left, key_right, key_up, login_url, ls, s, show, sight, slide_left, slide_tag, typing,
  __slice = Array.prototype.slice;

key_up = 38;

key_down = 40;

key_left = 37;

key_right = 39;

key_esc = 27;

key_enter = 13;

key_add = 65;

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

typing = false;

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
  var body, login, logio, logout, next, preview, render_login, tag;
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
    if (typing && (e.keyCode === key_esc)) {
      $('textarea').blur();
    } else {
      switch (e.keyCode) {
        case key_left:
          if (found(sight.prev())) slide_left(sight.prev());
          break;
        case key_right:
          if (found(sight.next())) slide_left(sight.next());
          break;
        case key_up:
          show('key_up');
          break;
        case key_down:
          show('key_down');
      }
    }
    if (ls.authed != null) {
      switch (e.keyCode) {
        case key_add:
          return show('key_add');
      }
    }
  });
  login = function() {
    return open(login_url);
  };
  logout = function() {
    s.emit('logout');
    preview('?', '?');
    logio.unbind('click', logout);
    logio.click(login);
    ls.removeItem('authed');
    ls.removeItem('key');
    return logio.text('click to login');
  };
  logio = $('#config .login span');
  logio.click(login);
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
      $('#nick').val(data.login);
    }
    if (data.state != null) {
      $('#config .state').text(data.state);
      $('#state').val(data.state);
    }
    logio.unbind('click', login);
    logio.click(logout);
    ls.authed = 'yes';
    return logio.text('logout');
  };
  return s.on('login', render_login);
});
