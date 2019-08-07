//
const merge = require('webpack-merge');

module.exports = function(env, argv) {
  if(argv.host) {
    // We're running on the webpack-dev-server and always
    // use a stable publicPath
    env.publicPath = '/assets/';
  }

  let common = require('./webpack.common.js')(env);

  return merge(common, {
    mode: 'development',
    devtool: 'inline-source-map',

    stats: {
      errorDetails: true,
    },

    output: {
      pathinfo: true,
    },

    devServer: {
      compress: true,
      contentBase: '/assets/',
      headers: { 'Access-Control-Allow-Origin': '*' },
      historyApiFallback: true,
      host: '0.0.0.0',
      port: 9000,
      proxy: { '/': 'http://localhost:9001' },
      // publicPath: env.publicPath,
      watchOptions: {
        ignored: /node_modules/
      }
    }
  });
};
