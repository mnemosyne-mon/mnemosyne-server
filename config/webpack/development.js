// Note: You must restart bin/webpack-dev-server for changes to take effect
process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const merge = require('webpack-merge')

const environment = require('./environment.js')
const { config, output } = require('./configuration.js')

module.exports = merge(environment, {
  mode: 'development',

  stats: {
    errorDetails: true
  },

  output: {
    pathinfo: true
  },

  devServer: {
    clientLogLevel: 'none',
    https: false,
    host: config.dev_server.host,
    port: config.dev_server.port,
    proxy: {'/': 'http://localhost:9001'},
    contentBase: config.output,
    publicPath: output.publicPath,
    compress: true,
    headers: { 'Access-Control-Allow-Origin': '*' },
    historyApiFallback: true,
    watchOptions: {
      ignored: /node_modules/
    }
  }
})
