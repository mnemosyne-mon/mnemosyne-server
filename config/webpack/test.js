// Note: You must restart bin/webpack-dev-server for changes to take effect
process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const merge = require('webpack-merge')
const environment = require('./environment.js')

module.exports = merge(environment, {})
