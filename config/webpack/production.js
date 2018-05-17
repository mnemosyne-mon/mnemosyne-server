// Note: You must restart bin/webpack-dev-server for changes to take effect
process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const merge = require('webpack-merge')

const MinifyPlugin = require('babel-minify-webpack-plugin')
const CompressionPlugin = require('compression-webpack-plugin')

const environment = require('./environment.js')

module.exports = merge(environment, {
  mode: 'none',

  plugins: [
    new MinifyPlugin({}, {
      test: /\.jsx?$/i,
      sourceMap: false,
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
    })
  ]
})
