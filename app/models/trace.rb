# frozen_string_literal: true

class Trace < ApplicationRecord
  include Duration

  attribute :start, ::Mnemosyne::Types::PreciseDateTime.new
  attribute :stop, ::Mnemosyne::Types::PreciseDateTime.new

  attribute :id, ::Mnemosyne::Types::UUID4.new
  attribute :origin_id, ::Mnemosyne::Types::UUID4.new
  attribute :activity_id, ::Mnemosyne::Types::UUID4.new

  has_many :spans, -> { order('start') }

  belongs_to :application
  belongs_to :activity
  belongs_to :platform
  belongs_to :origin, class_name: 'Span', optional: true
end
