var watchDir = __dirname + "/R"

var livereload = require('livereload');
var server = livereload.createServer({
  exts: ['R'],
  debug: true
});
server.watch(watchDir);
