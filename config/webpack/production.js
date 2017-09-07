// Note: You must restart bin/webpack-dev-server for changes to take effect

/* eslint global-require: 0 */

const webpack = require('webpack')
const merge = require('webpack-merge')

const CompressionPlugin = require('compression-webpack-plugin')
const ClosureCompiler   = require('google-closure-compiler-js').webpack

const sharedConfig = require('./shared.js')

module.exports = merge(sharedConfig, {
  devtool: 'source-map',
  plugins: [
    new ClosureCompiler({
      options: {
        languageIn: 'ECMASCRIPT_2017',
        languageOut: 'ECMASCRIPT_2017',
        compilationLevel: 'SIMPLE',
        warningLevel: 'QUIET',
      }
    }),
    new CompressionPlugin({
      asset: '[path].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf)$/
    })
  ]
})
