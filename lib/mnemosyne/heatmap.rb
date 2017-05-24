# frozen_string_literal: true

module Mnemosyne
  class Heatmap
    using ::Mnemosyne::Refinements::Arel::Grouping

    def initialize
      @column_name = :stop
      @start = Time.zone.now
    end

    def as_json(*args)
      {
        data: execute
      }.as_json(*args)
    end

    # Number of latency buckets
    #
    def latency_bucket_count
      20
    end

    # Latency bucket size in microseconds
    #
    def latency_interval
      10_000
    end

    # Number of time buckets
    #
    def time_bucket_count
      30
    end

    # Size of each time bucket in seconds
    #
    def time_interval
      60
    end

    def time_start
      (@start.to_i / time_interval * time_interval) -
        (time_interval * time_bucket_count)
    end

    # Iterate over each column
    #
    def each
      latency_bucket_count.times.reverse_each do |i|
        yield Row.new self, i
      end
    end

    def value_at(row, col)
      if (field = data[[column_value_at(col), row_value_at(row)]])
        field.first['count']
      else
        0
      end
    end

    def row_value_at(idx)
      idx * latency_interval
    end

    def column_value_at(idx)
      time_start + (idx * time_interval)
    end

    def data
      @data ||= execute.group_by {|h| [h['time'], h['latency']] }
    end

    private

    attr_reader :column_name, :timeseries, :latseries

    def execute
      ActiveRecord::Base.connection.execute(create_query.to_sql).to_a
    end

    # rubocop:disable MethodLength, AbcSize, LineLength
    def create_query
      ts_size = time_interval * 1_000_000_000
      ts_strt = ::Mnemosyne::Clock.to_tick(@start - (time_interval * time_bucket_count))
      ts_stop = ::Mnemosyne::Clock.to_tick(@start)

      ls_size = latency_interval * 1_000
      ls_strt = 0
      ls_stop = ls_size * latency_bucket_count

      traces = Arel::Table.new(:traces)
      column = traces[column_name]

      t_cte = Arel::Table.new(:t_0)
      s_cte = traces
        .project(
          traces[:id],
          (column / ts_size * ts_size).as('ts'),
          ((traces[:stop] - traces[:start]) / ls_size * ls_size).as('ls')
        )
        .where([
          column.gt(ts_strt),
          column.lteq(ts_stop),
          (traces[:stop] - traces[:start]).gt(ls_strt),
          (traces[:stop] - traces[:start]).lteq(ls_stop)
        ].reduce(&:and))

      w_cte = Arel::Nodes::As.new(t_cte, s_cte)

      t_cte
        .project(
          (t_cte[:ts] / 1_000_000_000).as('time'),
          (t_cte[:ls] / 1_000).as('latency'),
          t_cte[:id].count.as('count')
        )
        .with(w_cte)
        .group(t_cte[:ts], t_cte[:ls])
        .order(t_cte[:ls], t_cte[:ts])
    end

    Row = Struct.new(:heatmap, :row_index) do
      def latency
        row_index * heatmap.latency_interval
      end

      def each
        heatmap.time_bucket_count.times do |i|
          yield Column.new heatmap, row_index, i
        end
      end
    end

    Column = Struct.new(:heatmap, :row_index, :column_index) do
      def value
        heatmap.value_at(row_index, column_index)
      end
    end
  end
end
