var json2page, out, render_style;

json2page = function(data) {
  var attrs, check, css, html, item, key, match, parse, tags, value, _i, _id, _j, _k, _len, _len2, _len3, _ref, _tag;
  if (typeof data === 'string') return ">" + data;
  html = '';
  attrs = [];
  tags = [];
  for (key in data) {
    value = data[key];
    parse = key.match(/^(\w*)\$(\w*)$/);
    if (parse) {
      tags.push({
        id: parse[1],
        tag: parse[2],
        value: value
      });
    } else if (check = key.match(/^[a-zA-Z_]\w+$/)) {
      attrs.push(key);
    }
  }
  css = [];
  for (_i = 0, _len = attrs.length; _i < _len; _i++) {
    item = attrs[_i];
    if (item.match(/^style\d*$/)) {
      css.push(item);
    } else if (typeof data[item] === 'string') {
      html += "" + item + "='" + data[item] + "'";
    }
  }
  if (css.length > 0) {
    html += "style='";
    for (_j = 0, _len2 = css.length; _j < _len2; _j++) {
      item = css[_j];
      _ref = data[item];
      for (key in _ref) {
        value = _ref[key];
        html += "" + key + ":";
        if (typeof value === 'string') {
          html += "" + value + ";";
        } else {
          html += "" + value + "px;";
        }
      }
    }
    html += "'";
  }
  html += '>';
  for (_k = 0, _len3 = tags.length; _k < _len3; _k++) {
    item = tags[_k];
    if (item.tag.match(/^pipe\d*$/)) {
      html += (json2page(item.value)).slice(1);
    } else {
      _id = item.id;
      _tag = item.tag || 'div';
      match = _tag.match(/^([a-z]+)\d*$/);
      if (_tag.match(/^page\d*$/)) {
        html += item.value;
      } else if (_tag.match(/^text\d*/)) {
        html += item.value.replace('<', '&lt;').replace('>', '&gt;').replace(' ', '&nbsp;');
      } else {
        html += "<" + match[1] + " ";
        if (_id) html += "id='" + _id + "'";
        if (_tag.match(/^style\d*$/)) {
          html += '>';
          html += render_style(item.value);
          html += '</style>';
        } else {
          html += json2page(item.value);
          html += "</" + match[1] + ">";
        }
      }
    }
  }
  return html;
};

render_style = function(data) {
  var attr, content, key, match, style, value;
  style = '';
  for (key in data) {
    value = data[key];
    style += "" + key + "\{";
    for (attr in value) {
      content = value[attr];
      if (match = attr.match(/^([a-z-]+)\d*$/)) style += "" + match[1] + ":";
      if (typeof content === 'number') {
        style += "" + content + "px;";
      } else {
        style += "" + content + ";";
      }
    }
    style += '\}';
  }
  return style;
};

/*
err = (e) ->
  o 'Error: ', e
o = console.log or (v...)->null

data =
  $head:
    $meta:
      charset: 'utf-8'
    $link:
      rel: 'stylesheet'
      href: 'path/to/css/file'
  $style:
    body:
      padding: 'dd'
      "-moz-box-shadow": '0px 0px 0px red'
    'nav:hover':
      background: 'red'
  $body:
    style:
      display: '-moz-box'
      display1: 'box'
      background: 'hsl(0,80%,80%)'
    style1:
      width: 1
    $text: 'line 1'
    $text1: 'line 2<>'
    $page: 'page  <br/>'
    $span:
      style:
        width: 111
      $text: 'nothin  g'
    $span1: '3'
    id_here$span1: 'add'
    $pipe:
      $text: 'qq'
o (json2page data)[1..]

data =
  $p:
    $text: '<text >'
    $page: '<page >'
console.log (json2page data)[1..]
*/

out = function(data) {
  return (json2page(data)).slice(1);
};

if (typeof window !== "undefined" && window !== null) window.json2page = out;

if (typeof exports !== "undefined" && exports !== null) exports.json2page = out;
