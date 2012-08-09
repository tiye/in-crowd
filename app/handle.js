var nav;

nav = "  <p> Topic List </p>  <p> Set Name </p>  ";

$(function() {
  var b, h, view;
  h = $('#nav');
  b = $('#box');
  view = 'room';
  return h.click(function() {
    console.log(nav);
    return b.html(nav);
  });
});
