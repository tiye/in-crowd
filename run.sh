
coffee --output ./ --bare --compile source/server.coffee && echo server.js
coffee --output public/ --bare --compile source/client.coffee && echo public/client.js
jade source/index.jade --out public/
stylus -o public/ -c source/page.styl
node server.js
