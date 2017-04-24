/* eslint global-require: 0 */
// Note: You must run bin/webpack for changes to take effect

const webpack = require('webpack')
const merge = require('webpack-merge')
const CompressionPlugin = require('compression-webpack-plugin')
const common = require('./common.js')

module.exports = merge(common, {
  output: { filename: '[name]-[chunkhash].js' },

  plugins: [
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|svg|eot|ttf|woff|woff2)$/
    })
  ]
})
