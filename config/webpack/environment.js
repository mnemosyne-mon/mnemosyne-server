//
const webpack = require('webpack')

const MiniCssExtractPlugin = require("mini-css-extract-plugin")
const ManifestPlugin       = require('webpack-manifest-plugin')

const { join, resolve } = require('path')
const { config, env, devMode, output } = require('./configuration')

module.exports = {
  entry: {
    application: ['manifest.js', 'main.js', 'main.sass']
  },

  output: {
    path: output.path,
    filename: devMode ? '[name].js' : '[chunkhash:20].js'
  },

  context: resolve(config.source),

  module: {
    rules: [{
      test: /\.(ico|eot|ttf|woff|woff2)$/i,
      use: [{
        loader: 'file-loader',
        options: { name: devMode ? '[path][name].[ext]' : '[hash:20].[ext]' }
      }]
    }, {
      test: /\.(jpe?g|png|gif|svg)$/i,
      use: [{
        loader: 'file-loader',
        options: { name: devMode ? '[path][name].[ext]' : '[hash:20].[ext]' }
      },{
        loader: 'image-webpack-loader',
        options: {}
      }]
    }, {
      test: /\.(scss|sass|css)$/i,
      use: [
        MiniCssExtractPlugin.loader,
      {
        loader: 'cache-loader',
        options: {
          cacheDirectory: resolve('tmp/cache/webpack')
        }
      }, {
        loader: 'css-loader',
        options: {
          sourceMap: true,
          importLoaders: 2
        }
      }, {
        loader: 'postcss-loader',
        options: {
          sourceMap: true,
          plugins: () => [
            require('autoprefixer')({browsers: ['last 1 chrome versions']})
          ]
        }
      }, {
        loader: 'sass-loader',
        options: {
          sourceMap: true
        }
      }]
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
            ['@babel/preset-env', {
              targets: {browsers: ['last 1 chrome versions']},
              modules: false,
              loose: true
            }]
          ],
          plugins: [
            ['@babel/plugin-transform-react-jsx', {pragma: 'h'}]
          ]
        },
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
            ['@babel/preset-env', {
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
    }),
    new webpack.EnvironmentPlugin(['NODE_ENV']),
    new MiniCssExtractPlugin({
      filename: devMode ? '[name].css' : '[hash].css',
      chunkFilename: devMode ? '[id].css' : '[id].[hash].css',
    }),
    new ManifestPlugin({
      fileName: 'manifest.json',
      writeToFileEmit: true,
      publicPath: output.publicPath
    })
  ],

  resolve: {
    alias: {
      bourbon: 'bourbon/app/assets/stylesheets'
    },
    extensions: [
      '.coffee', '.js', '.sass', '.scss', '.css', '.png', '.svg', '.jpg'
    ],
    modules: [
      resolve(config.source),
      resolve('node_modules')
    ]
  }
}
