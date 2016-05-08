class Span < ActiveRecord::Base
  include Duration

  attribute :start, ::Mnemosyne::Types::PreciseDateTime.new
  attribute :stop, ::Mnemosyne::Types::PreciseDateTime.new

  belongs_to :trace
end
