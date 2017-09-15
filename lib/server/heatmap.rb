# frozen_string_literal: true

module Server
  class Heatmap # rubocop:disable ClassLength
    using ::Server::Refinements::Arel::Grouping

    def initialize(traces, time: {}, latency: {})
      @traces = traces.unscope(:order, :limit, :select)
      @column_name = :stop

      @tseries = TimeSeries.new(**time)
      @lseries = LatencySeries.new(**latency)
    end

    def as_json(*args) # rubocop:disable MethodLength
      {
        time: {
          range: [
            @tseries.start.iso8601(9),
            @tseries.stop.iso8601(9)
          ],
          size: @tseries.size
        },
        latency: {
          range: [
            @lseries.start,
            @lseries.stop
          ],
          size: @lseries.size
        },
        values: execute
      }.as_json(*args)
    end

    # Iterate over each column
    #
    def each
      latency_bucket_count.times.reverse_each do |i|
        yield Row.new self, i
      end
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

    attr_reader :column_name, :max_count_sqrt

    def execute
      ActiveRecord::Base.connection
        .select_all(create_query, nil, @traces.where_clause.binds)
        .to_hash
    end

    # rubocop:disable MethodLength, AbcSize, LineLength
    def create_query
      tstart = Clock.to_tick(@tseries.start)
      tstop = Clock.to_tick(@tseries.stop)
      tsize = Clock.to_tick(@tseries.interval)

      lstart = @lseries.start
      lstop = @lseries.stop
      lsize = @lseries.interval

      traces = Arel::Table.new(:traces)
      column = traces[column_name]

      t_cte = Arel::Table.new(:buckets)
      s_cte = @traces.select(:id).arel
        .project(
          ((column - tstart) / tsize).as('ts'),
          ((traces[:stop] - traces[:start] - lstart) / lsize).as('ls')
        )
        .where([
          column.gt(tstart),
          column.lteq(tstop),
          (traces[:stop] - traces[:start]).gt(lstart),
          (traces[:stop] - traces[:start]).lteq(lstop)
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
