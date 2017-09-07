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
    // new webpack.optimize.UglifyJsPlugin({
    //   minimize: true,
    //   sourceMap: true,
    //   compress: {
    //     warnings: false
    //   },
    //   output: {
    //     comments: false
    //   }
    // }),
    new ClosureCompiler({
      compiler: {
        languageIn: 'ECMASCRIPT_NEXT',
        languageOut: 'ECMASCRIPT_NEXT',
        compilationLevel: 'ADVANCED',
        formatting: 'PRETTY_PRINT',
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
