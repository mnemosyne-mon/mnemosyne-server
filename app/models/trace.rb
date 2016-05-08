class Trace < ActiveRecord::Base
  attribute :start, ::Mnemosyne::Types::PreciseDateTime.new
end
