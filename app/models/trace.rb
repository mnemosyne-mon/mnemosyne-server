# frozen_string_literal: true

class Trace < ApplicationRecord
  self.primary_key = 'id'

  extend Concerns::Model::Range
  include Concerns::Model::Duration

  attribute :id, :uuid
  attribute :origin_id, :uuid
  attribute :platform_id, :uuid
  attribute :application_id, :uuid

  attribute :start, ::Server::Types::PreciseDateTime.new
  attribute :stop, ::Server::Types::PreciseDateTime.new

  has_many :spans, -> { order('start') }
  has_many :failures

  belongs_to :application
  belongs_to :activity
  belongs_to :platform
  belongs_to :origin, class_name: 'Span', optional: true

  class << self
    def retention(period, time = Time.zone.now)
      period = ::Server::Types::Duration.new.cast_value(period)
      tlimit = time - period

      where t[:stop].lt(tlimit).and(t[:store].eq(false))
    end

    alias t arel_table
  end
end
