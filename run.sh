
coffee --output ./ --bare --compile source/server.coffee && echo server.js
jade source/index.jade --out public/
stylus -o public/ -c source/page.styl
node server.js
