# frozen_string_literal: true

class Span < ApplicationRecord
  include Duration

  attribute :start, ::Mnemosyne::Types::PreciseDateTime.new
  attribute :stop, ::Mnemosyne::Types::PreciseDateTime.new

  belongs_to :trace
  has_many :traces, foreign_key: :origin_id, class_name: :Trace
end
