# frozen_string_literal: true

class Span < ApplicationRecord
  self.primary_key = 'id'

  extend Concerns::Model::Range
  include Concerns::Model::Duration

  attribute :start, ::Server::Types::PreciseDateTime.new
  attribute :stop, ::Server::Types::PreciseDateTime.new

  belongs_to :trace
  belongs_to :platform

  has_many :traces, foreign_key: :origin_id, class_name: :Trace

  class << self
    def retention(period, time = Time.zone.now)
      period = ::Server::Types::Duration.new.cast_value(period)
      tlimit = time - period

      where t[:stop].lt(tlimit)
    end

    alias t arel_table
  end
end
