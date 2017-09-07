// Note: You must restart bin/webpack-dev-server for changes to take effect

const merge = require('webpack-merge')

const sharedConfig = require('./shared.js')
const { settings, output } = require('./configuration.js')

module.exports = merge(sharedConfig, {
  devtool: 'source-map',

  stats: {
    errorDetails: true
  },

  output: {
    pathinfo: true
  },

  devServer: {
    // host: devServer.host,
    // port: devServer.port,
    // disableHostCheck: true,
    // contentBase: resolve(paths.output, paths.entry),
    // proxy: {'/': 'http://localhost:9001'},
    // publicPath

    clientLogLevel: 'none',
    https: settings.dev_server.https,
    host: settings.dev_server.host,
    port: settings.dev_server.port,
    proxy: {'/': 'http://localhost:9001'},
    contentBase: output.path,
    publicPath: output.publicPath,
    compress: true,
    headers: { 'Access-Control-Allow-Origin': '*' },
    historyApiFallback: true,
    watchOptions: {
      ignored: /node_modules/
    }
  }
})
