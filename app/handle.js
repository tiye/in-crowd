var authed, found, key_add, key_down, key_enter, key_esc, key_left, key_right, key_up, login_url, ls, s, show, sight, slide_left, slide_tag, typing,
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

typing = false;

sight = void 0;

authed = false;

slide_tag = function(value) {
  if (value != null) {
    return localStorage.slide_left = value;
  } else {
    return localStorage.slide_left;
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

ls = localStorage;

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

if (ls.key != null) s.emit('key', ls.key);

$(function() {
  var body, next, tag;
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
    if (typing && e.keyCode === key_esc) {
      return $('textarea').blur();
    } else if (authed) {
      switch (e.keyCode) {
        case key_add:
          return show('key_add');
      }
    } else {
      switch (e.keyCode) {
        case key_left:
          if (found(sight.prev())) return slide_left(sight.prev());
          break;
        case key_right:
          if (found(sight.next())) return slide_left(sight.next());
          break;
        case key_up:
          return show('key_up');
        case key_down:
          return show('key_down');
      }
    }
  });
  $('#config .login span').click(function() {
    show('open');
    return open(login_url);
  });
  return s.on('login', function(data) {
    data = JSON.parse(data);
    $('#config img').attr('src', data.avatar_url);
    show('then');
    return $('#config .name').text(data.login);
  });
});
