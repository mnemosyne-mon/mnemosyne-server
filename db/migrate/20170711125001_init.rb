# frozen_string_literal: true

class Init < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'plpgsql'
    enable_extension 'pgcrypto'
    enable_extension 'timescaledb'

    create_table :activities, id: :uuid do |t|
      t.uuid :platform_id, null: false

      t.timestamps
    end

    create_table :applications, id: :uuid do |t|
      t.string :title
      t.string :name, null: false

      t.uuid   :platform_id, null: false

      t.timestamps

      t.index %i[platform_id name], unique: true
    end

    create_table :platforms, id: :uuid do |t|
      t.string   :title
      t.string   :name,             null: false
      t.interval :retention_period, default: 'P14D'
      t.timestamps

      t.index %i[name], unique: true
    end

    create_table :spans, id: false do |t|
      t.uuid :id, null: false, default: 'gen_random_uuid()'

      t.string :name,     null: false
      t.bigint :start,    null: false
      t.bigint :stop,     null: false
      t.jsonb  :meta

      t.uuid   :trace_id,    null: false
      t.uuid   :platform_id, null: false

      t.timestamps

      t.index %i[name]
      t.index %i[start]
      t.index %i[trace_id]
    end

    create_table :traces, id: false do |t|
      t.uuid    :id,       null: false, default: 'gen_random_uuid()'

      t.string  :name,     null: false
      t.string  :hostname, null: false
      t.bigint  :start,    null: false
      t.bigint  :stop,     null: false
      t.boolean :store,    null: false, default: false
      t.jsonb   :meta

      t.uuid :application_id, null: false
      t.uuid :activity_id, null: false
      t.uuid :platform_id, null: false
      t.uuid :origin_id

      t.timestamps

      t.index %i[name]
      t.index %i[hostname]
      t.index %i[origin_id]
      t.index %i[platform_id]
      t.index %i[meta], using: :gin
      t.index %i[stop], order: {stop: :desc}
      t.index "((meta ->> 'method'::text))", name: 'idx_traces_filter_method'
    end

    execute <<-SQL.strip_heredoc
      SELECT create_hypertable(
        'traces'::regclass, 'stop'::name,
        chunk_time_interval => 21600000000000);
    SQL

    execute <<-SQL.strip_heredoc
      SELECT create_hypertable(
        'spans'::regclass, 'stop'::name,
        chunk_time_interval => 21600000000000);
    SQL
  end
end
