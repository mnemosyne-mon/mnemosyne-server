# frozen_string_literal: true

require 'server/pipeline'

pipeline = Rails.application.config_for('pipeline')

if (config = pipeline['influx'])
  database = config.fetch('database')
  host     = config['host']
  username = config['username']
  password = config['password']

  kwargs = {
    host: host,
    async: true,
    username: username,
    password: password,
    time_precision: 'ns',
  }

  ::Server::Pipeline.default.use \
    ::Server::Pipeline::Metrics::Influx.new(database, **kwargs)
end
