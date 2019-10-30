# frozen_string_literal: true

::ActionController::Renderers.add :csv do |list, _opts|
  encoder = Enumerator.new do |y|
    list.each do |row|
      y << row.as_csv.to_csv
    end
  end

  headers['Content-Type'] = 'text/csv'
  headers['Content-Disposition'] = 'attachment; filename="data.csv"'
  headers['Cache-Control'] ||= 'no-cache'
  headers['Transfer-Encoding'] = 'chunked'
  headers.delete('Content-Length')

  Rack::Chunked::Body.new(encoder)
end
