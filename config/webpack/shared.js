// Note: You must restart bin/webpack-watcher for changes to take effect
/* eslint global-require: 0 */
/* eslint import/no-dynamic-require: 0 */

const webpack      = require('webpack')
const autoprefixer = require('autoprefixer')
const csswring     = require('csswring')

const ExtractTextPlugin = require('extract-text-webpack-plugin')
const ManifestPlugin    = require('webpack-manifest-plugin')

const { join, resolve } = require('path')
const { env, settings, output, loadersDir } = require('./configuration.js')

if(env.NODE_ENV === 'production') {
  JAVASCRIPT_NAME = '[chunkhash:20].js'
  STYLESHEET_NAME = '[contenthash:20].css'
  FILE_NAME       = '[hash:20].[ext]'
} else {
  JAVASCRIPT_NAME = '[name].js'
  STYLESHEET_NAME = '[name].css'
  FILE_NAME       = '[path][name].[ext]'
}

module.exports = {
  entry: {
    application: ['manifest.js', 'main.js', 'main.sass']
  },

  context: resolve(settings.source),

  output: {
    path: resolve(settings.output),
    filename: JAVASCRIPT_NAME,
    publicPath: output.publicPath
  },

  module: {
    rules: [{
      test: /\.(ico|eot|ttf|woff|woff2)$/i,
      use: [{
        loader: 'file-loader',
        options: { name: FILE_NAME }
      }]
    }, {
      test: /\.(jpe?g|png|gif|svg)$/i,
      use: [{
        loader: 'file-loader',
        options: { name: FILE_NAME }
      },{
        loader: 'image-webpack-loader',
        options: {}
      }]
    }, {
      test: /\.(scss|sass|css)$/i,
      use: ExtractTextPlugin.extract({
        use: [{
          loader: 'cache-loader',
          options: {
            cacheDirectory: resolve('tmp/cache/webpack')
          }
        }, {
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
              require('autoprefixer')({browsers: ['last 1 chrome versions']}),
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
      test: /\.jsx?$/i,
      use: [{
        loader: 'cache-loader',
        options: {
          cacheDirectory: resolve('tmp/cache/webpack')
        }
      }, {
        loader: 'babel-loader',
        options: {
          presets: [
            ['env', {
              targets: {browsers: ['last 1 chrome versions']},
              modules: false,
              loose: true
            }],
            'react'
          ]
        }
      }]
    }, {
      test: /\.coffee$/i,
      exclude: /node_modules/,
      use: [{
        loader: 'cache-loader',
        options: {
          cacheDirectory: resolve('tmp/cache/webpack')
        }
      }, {
        loader: 'babel-loader',
        options: {
          presets: [
            ['env', {
              targets: {browsers: ['last 1 chrome versions']},
              modules: false,
              loose: true
            }]
          ]
        }
      }, {
        loader: 'coffee-loader'
      }]
    }]
  },

  plugins: [
    new webpack.optimize.ModuleConcatenationPlugin(),
    new webpack.ProvidePlugin({
      '$': 'jquery',
      'jquery': 'jquery',
      'jQuery': 'jquery',
      'window.jQuery': 'jquery',
      'Tether': 'tether'
    }),
    new webpack.EnvironmentPlugin(JSON.parse(JSON.stringify(env))),
    new ExtractTextPlugin(STYLESHEET_NAME),
    new ManifestPlugin({
      fileName: settings.manifest,
      writeToFileEmit: true,
      publicPath: output.publicPath
    })
  ],

  resolve: {
    alias: {
      // bootstrap: 'bootstrap/scss',
      bourbon: 'bourbon/app/assets/stylesheets'
    },
    extensions: [
      '.coffee', '.js', '.sass', '.scss', '.css', '.png', '.svg', '.jpg'
    ],
    modules: [
      resolve(settings.source),
      'node_modules'
    ]
  },

  resolveLoader: {
    modules: ['node_modules']
  }
}
