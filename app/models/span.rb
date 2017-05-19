# frozen_string_literal: true

class Span < ApplicationRecord
  include Duration

  attribute :start, ::Mnemosyne::Types::PreciseDateTime.new
  attribute :stop, ::Mnemosyne::Types::PreciseDateTime.new

  belongs_to :trace
  has_one :origin, foreign_key: :origin_id, class_name: :Trace

  def title
    case name
      when 'app.controller.request.rails'
        "#{name} <#{meta['controller']}##{meta['action']}>"
      when 'db.query.active_record'
        "#{name} <#{meta['sql']}>"
      when 'custom.trace'
        "custom.trace <#{meta['name']} #{meta['meta'].to_json}>"
      when /external\.http\.\w+(\.\w+)?/
        "#{name} <#{meta['method'].upcase} #{meta['url']}>"
      else
        "#{name} <#{meta.keys.join(', ')}>"
    end
  end
end
