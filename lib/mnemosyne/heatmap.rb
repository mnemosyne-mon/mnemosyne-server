# frozen_string_literal: true

module Mnemosyne
  class Heatmap
    using ::Mnemosyne::Refinements::Arel::Grouping

    def initialize(platform)
      @platform = platform
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
      100
    end

    # Latency bucket size in microseconds
    #
    def latency_interval
      20_000
    end

    def latency_start
      0
    end

    # Number of time buckets
    #
    def time_bucket_count
      260
    end

    # Size of each time bucket in seconds
    #
    def time_interval
      600
    end

    # Iterate over each column
    #
    def each
      latency_bucket_count.times.reverse_each do |i|
        yield Row.new self, i
      end
    end

    def value_at(row, col)
      if (field = data[[col, row]])
        field.first['count']
      else
        0
      end
    end

    def latency_at(idx)
      latency_start + idx * latency_interval
    end

    def time_at(idx)
      @start - (time_bucket_count - idx) * time_interval
    end

    def data
      @data ||= begin
        data = execute

        @max_count = data.map {|h| h['count'] }.max
        @max_count_sqrt = normalize(@max_count)
        @data = data.group_by {|h| [h['time'], h['latency']] }
      end
    end

    def normalize(value)
      Math.sqrt(Math.sqrt(Math.sqrt(value))) - 0.9
    end

    # private

    attr_reader :column_name, :timeseries, :latseries, :max_count_sqrt

    def execute
      ActiveRecord::Base.connection.execute(create_query.to_sql).to_a
    end

    # rubocop:disable MethodLength, AbcSize, LineLength
    def create_query
      ts_size = time_interval * 1_000_000_000
      ts_strt = ::Mnemosyne::Clock.to_tick(@start - (time_interval * time_bucket_count))
      ts_stop = ::Mnemosyne::Clock.to_tick(@start)

      ls_size = latency_interval * 1_000
      ls_strt = latency_start * 1_000
      ls_stop = latency_start + ls_size * latency_bucket_count

      traces = Arel::Table.new(:traces)
      column = traces[column_name]

      t_cte = Arel::Table.new(:buckets)
      s_cte = traces
        .project(
          traces[:id],
          ((column - ts_strt) / ts_size).as('ts'),
          ((traces[:stop] - traces[:start] - ls_strt) / ls_size).as('ls')
        )
        .where([
          column.gt(ts_strt),
          column.lteq(ts_stop),
          (traces[:stop] - traces[:start]).gt(ls_strt),
          (traces[:stop] - traces[:start]).lteq(ls_stop),
          traces[:origin_id].eq(nil),
          traces[:platform_id].eq(@platform.to_s)
        ].reduce(&:and))

      w_cte = Arel::Nodes::As.new(t_cte, s_cte)

      t_cte
        .project(
          # (t_cte[:ts] / 1_000_000_000).as('time'),
          # (t_cte[:ls] / 1_000).as('latency'),
          (t_cte[:ts]).as('time'),
          (t_cte[:ls]).as('latency'),
          t_cte[:id].count.as('count')
        )
        .with(w_cte)
        .group(t_cte[:ts], t_cte[:ls])
        .order(t_cte[:ls], t_cte[:ts])
    end

    Row = Struct.new(:heatmap, :row_index) do
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

      def weight
        [255, ((heatmap.normalize(value) / heatmap.max_count_sqrt.to_f) * 255).to_i].min
      end
    end
  end
end
