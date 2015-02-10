livereload = require('livereload');
server = livereload.createServer({
  exts: ['R']
});
server.watch(__dirname + "/app");
