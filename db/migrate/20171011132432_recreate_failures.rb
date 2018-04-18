# frozen_string_literal: true

class RecreateFailures < ActiveRecord::Migration[5.1]
  # rubocop:disable AbcSize
  # rubocop:disable MethodLength
  def up
    drop_table :failures

    create_table :failures, id: false do |t|
      t.uuid   :id, null: false, default: 'gen_random_uuid()'

      t.string :type, null: false
      t.text   :text, null: false
      t.string :hostname, null: false
      t.jsonb  :stacktrace, null: false

      t.uuid :trace_id, null: false
      t.uuid :platform_id, null: false
      t.uuid :application_id, null: false

      t.bigint :stop, null: false

      t.timestamps

      t.index %i[type]
      t.index %i[hostname]
      t.index %i[trace_id]
      t.index %i[platform_id]
      t.index %i[application_id]
      t.index %i[stop], order: {stop: :desc}
    end

    return unless timescaledb?

    execute <<-SQL.strip_heredoc
      SELECT create_hypertable(
        'failures'::regclass, 'stop'::name,
        chunk_time_interval => 86400000000000);
    SQL
  end

  def down
    drop_table :failures

    create_table :failures, id: :uuid do |t|
      t.string :type, null: false
      t.text   :text, null: false
      t.jsonb  :stacktrace, null: false

      t.uuid :trace_id, null: false
      t.uuid :platform_id, null: false

      t.timestamps
    end
  end

  def timescaledb?
    !%w[off false 0].include?(ENV['TIMESCALEDB'])
  end
end
