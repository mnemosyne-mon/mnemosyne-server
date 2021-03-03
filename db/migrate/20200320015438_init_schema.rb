# frozen_string_literal: true

class InitSchema < ActiveRecord::Migration[6.0]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension 'pgcrypto'
    enable_extension 'plpgsql'
    enable_extension 'timescaledb' if timescaledb?

    create_table :applications, id: :uuid do |t|
      t.string 'title'
      t.string 'name', null: false
      t.uuid 'platform_id', null: false
      t.timestamps null: false
      t.index %i[platform_id name], unique: true
    end

    create_table :platforms, id: :uuid do |t|
      t.string 'title'
      t.string 'name', null: false, index: {unique: true}
      t.interval 'retention_period', default: 'P14D'
      t.timestamps null: false
    end

    create_table :failures, id: false do |t|
      t.uuid 'id', null: false, index: true, default: 'gen_random_uuid()'

      t.string 'type', null: false, index: true
      t.text 'text', null: false
      t.string 'hostname', null: false, index: true
      t.jsonb 'stacktrace', null: false
      t.uuid 'trace_id', null: false, index: true
      t.uuid 'platform_id', null: false, index: true
      t.uuid 'application_id', null: false, index: true
      t.timestamp 'stop', null: false, index: {order: :desc}
      t.timestamps null: false
    end

    create_table 'spans', id: false do |t|
      t.uuid 'id', null: false, index: true, default: 'gen_random_uuid()'
      t.string 'name', null: false, index: true
      t.timestamp 'start', null: false, index: true
      t.timestamp 'stop', null: false, index: {order: :desc}
      t.jsonb 'meta'
      t.uuid 'trace_id', null: false, index: true
      t.uuid 'platform_id', null: false
      t.timestamps null: false
    end

    create_table 'traces', id: false do |t|
      t.uuid 'id', null: false, index: true, default: -> { 'gen_random_uuid()' }
      t.string 'name', null: false, index: true
      t.string 'hostname', null: false, index: true
      t.timestamp 'start', null: false
      t.timestamp 'stop', null: false, index: {order: :desc}
      t.boolean 'store', default: false, null: false
      t.jsonb 'meta', index: {using: :gin}
      t.uuid 'application_id', null: false, index: true
      t.uuid 'activity_id', null: false, index: true
      t.uuid 'platform_id', null: false, index: true
      t.uuid 'origin_id', index: true
      t.timestamps null: false

      t.index "((meta ->> 'method'::text))", name: 'index_traces_meta_method'
      t.index '((stop - start))', name: 'index_traces_duration'
    end

    if timescaledb? # rubocop:disable Style/GuardClause
      execute <<~SQL.squish
        SELECT create_hypertable(
          'traces'::regclass, 'stop'::name,
          chunk_time_interval => interval '6h');
      SQL

      execute <<~SQL.squish
        SELECT create_hypertable(
          'spans'::regclass, 'stop'::name,
          chunk_time_interval => interval '6h');
      SQL

      execute <<~SQL.squish
        SELECT create_hypertable(
          'failures'::regclass, 'stop'::name,
          chunk_time_interval => interval '6h');
      SQL
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration.new('The initial migration is not revertable')
  end

  def timescaledb?
    %w[off false 0].exclude?(ENV['TIMESCALEDB'])
  end
end
