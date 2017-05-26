// Note: You must restart bin/webpack-watcher for changes to take effect
/* eslint global-require: 0 */
/* eslint import/no-dynamic-require: 0 */

const webpack      = require('webpack')
const autoprefixer = require('autoprefixer')
const csswring     = require('csswring')

const ExtractTextPlugin = require('extract-text-webpack-plugin')
const ManifestPlugin    = require('webpack-manifest-plugin')

const { join, resolve } = require('path')
const { env, paths, publicPath, loadersDir } = require('./configuration.js')

if(env.NODE_ENV === 'production') {
  JAVASCRIPT_NAME = '[hash].js'
  STYLESHEET_NAME = '[hash].css'
  FILE_NAME = '[hash].[ext]'
} else {
  JAVASCRIPT_NAME = '[name].js'
  STYLESHEET_NAME = '[name].css'
  FILE_NAME = '[name].[ext]'
}

module.exports = {
  entry: {
    main: ['main.js', 'main.sass']
  },

  output: {
    path: resolve(paths.output),
    filename: JAVASCRIPT_NAME,
    publicPath
  },

  module: {
    rules: [{
      test: /\.(jpg|jpeg|png|gif|svg|eot|ttf|woff|woff2)$/i,
      use: [{
        loader: 'file-loader',
        options: { name: FILE_NAME }
      }]
    }, {
      test: /\.(scss|sass|css)$/i,
      use: ExtractTextPlugin.extract({
        use: [{
          loader: 'css-loader',
          options: {
            sourceMap: true,
            minimize: env.NODE_ENV === 'production',
            importLoaders: 2
          }
        }, {
          loader: 'postcss-loader',
          options: {
            sourceMap: true,
            plugins: () => [
              require('autoprefixer'),
              require('csswring')
            ]
          }
        }, {
          loader: 'sass-loader',
          options: {
            sourceMap: true
          }
        }]
      })
    }, {
      test: /\.(ls)$/i,
      use: [{
        loader: 'livescript-loader'
      }]
    }, {
      test: /\.(js)$/i,
      exclude: /node_modules/,
      use: [{
        loader: 'babel-loader',
        options: {
          presets: [
            ['env', {
              targets: {browsers: ['last 1 chrome versions']},
              modules: false,
              loose: true,
              debug: true
            }]
          ]
        }
      }]
    }]
  },

  plugins: [
    new webpack.ProvidePlugin({
      "$": "jquery",
      "jquery": "jquery",
      "jQuery": "jquery",
      "window.jQuery": "jquery"
    }),
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(env))),
    new ExtractTextPlugin(STYLESHEET_NAME),
    new ManifestPlugin({ fileName: paths.manifest, writeToFileEmit: true, publicPath })
  ],

  resolve: {
    alias: {
      bootstrap: 'bootstrap/scss',
      bourbon: 'bourbon/app/assets/stylesheets'
    },
    extensions: [
      '.coffee', '.js', '.sass', '.scss', '.css', '.png', '.svg', '.jpg'
    ],
    modules: [
      resolve(paths.source),
      resolve(paths.node_modules)
    ]
  },

  resolveLoader: {
    modules: [paths.node_modules]
  }
}
