# frozen_string_literal: true

module Mnemosyne
  class Heatmap # rubocop:disable ClassLength
    using ::Mnemosyne::Refinements::Arel::Grouping

    def initialize(traces)
      @traces = traces
      @column_name = :stop
      @start = Time.zone.now.change(sec: 0, usec: 0)
    end

    def as_json(*args) # rubocop:disable MethodLength
      {
        x: {
          range: [
            time_at(0).iso8601(9),
            time_at(time_bucket_count).iso8601(9)
          ],
          length: time_bucket_count
        },
        y: {
          range: [
            latency_at(0),
            latency_at(latency_bucket_count)
          ],
          length: latency_bucket_count
        },
        values: execute
      }.as_json(*args)
    end

    # Number of latency buckets
    #
    def latency_bucket_count
      79
    end

    # Latency bucket size in nanoseconds
    #
    def latency_interval
      25_000_000
    end

    def latency_start
      0
    end

    # Number of time buckets
    #
    def time_bucket_count
      96
    end

    # Size of each time bucket in nanoseconds
    #
    def time_interval
      37_500_000_000
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
      (latency_start + idx * latency_interval) / 1_000
    end

    def time_at(idx)
      offset = ::Mnemosyne::Clock.to_tick(@start)
      tindex = time_bucket_count - idx

      ::Mnemosyne::Clock.to_time(offset - tindex * time_interval)
    end

    def data
      @data ||= begin
        data = execute

        @max_count = data.map {|h| h['v'] }.max
        @max_count_sqrt = normalize(@max_count)
        @data = data.group_by {|h| [h['x'], h['y']] }
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
      ts_size = time_interval
      ts_stop = ::Mnemosyne::Clock.to_tick(@start)
      ts_strt = ::Mnemosyne::Clock.to_tick(@start) - (time_interval * time_bucket_count)

      ls_size = latency_interval
      ls_strt = latency_start
      ls_stop = latency_start + ls_size * latency_bucket_count

      traces = Arel::Table.new(:traces)
      column = traces[column_name]

      t_cte = Arel::Table.new(:buckets)
      s_cte = @traces.select(:id).arel
        .project(
          ((column - ts_strt) / ts_size).as('ts'),
          ((traces[:stop] - traces[:start] - ls_strt) / ls_size).as('ls')
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
          (t_cte[:ts]).as('x'),
          (t_cte[:ls]).as('y'),
          t_cte[:id].count.as('v')
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
