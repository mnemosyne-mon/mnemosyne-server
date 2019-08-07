//

module.exports = function(env = {}, argv) {
  if(argv.mode === undefined) {
    argv.mode = process.env.NODE_ENV || process.env.RAILS_ENV || 'development';
  }

  if(env.dev === undefined) {
    env.dev = argv.mode !== 'production';
  }

  if(env.publicPath === undefined) {
    env.publicPath = '/assets/';
  }

  if(env.dev) {
    return require('./webpack.dev.js')(env, argv);
  } else {
    return require('./webpack.prod.js')(env, argv);
  }
}
