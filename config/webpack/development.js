// Note: You must restart bin/webpack-watcher for changes to take effect

const merge = require('webpack-merge')
const common = require('./common.js')

const { resolve } = require('path')
const { devServer, publicPath, paths } = require('./configuration.js')

module.exports = merge(common, {
  devtool: 'sourcemap',

  stats: {
    errorDetails: true
  },

  output: {
    pathinfo: true
  },

  devServer: {
    host: devServer.host,
    port: devServer.port,
    contentBase: resolve(paths.output, paths.entry),
    publicPath
  }
})
