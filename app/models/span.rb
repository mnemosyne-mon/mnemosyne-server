# frozen_string_literal: true

class Span < ApplicationRecord
  self.primary_key = 'id'

  extend Model::Range
  include Model::Duration

  attribute :id, :uuid
  attribute :trace_id, :uuid
  attribute :platform_id, :uuid
  attribute :application_id, :uuid

  belongs_to :trace
  belongs_to :platform

  has_many :traces, foreign_key: :origin_id, dependent: :destroy, inverse_of: :origin

  class << self
    def retention(period, time = Time.zone.now)
      period = ::Server::Types::Duration.new.cast_value(period)
      tlimit = time - period

      where t[:stop].lt(tlimit)
    end

    alias t arel_table
  end
end
