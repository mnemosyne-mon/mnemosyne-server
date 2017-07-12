# frozen_string_literal: true

class Span < ApplicationRecord
  self.primary_key = 'id'

  include Duration

  attribute :start, ::Server::Types::PreciseDateTime.new
  attribute :stop, ::Server::Types::PreciseDateTime.new

  belongs_to :trace
  belongs_to :platform

  has_many :traces, foreign_key: :origin_id, class_name: :Trace
end
