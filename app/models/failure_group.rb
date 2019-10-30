# frozen_string_literal: true

require 'server/types/precise_date_time'

class FailureGroup < ApplicationRecord
  self.primary_key = 'id'
  self.table_name = 'failures'
  self.inheritance_column = '__no_column'

  default_scope { default }

  extend Model::Range

  attribute :platform_id, :uuid
  attribute :application_id, :uuid

  attribute :first_occurrence_at, ::Server::Types::PreciseDateTime.new
  attribute :last_occurrence_at, ::Server::Types::PreciseDateTime.new
  attribute :stop, ::Server::Types::PreciseDateTime.new

  belongs_to :platform
  belongs_to :application

  # The above .attribute seems to not work correctly
  def first_occurrence_at
    ::Server::Types::PreciseDateTime.new.cast(super)
  end

  # The above .attribute seems to not work correctly
  def last_occurrence_at
    ::Server::Types::PreciseDateTime.new.cast(super)
  end

  class << self
    # rubocop:disable AbcSize
    # rubocop:disable MethodLength
    def default
      select(
        t[:type],
        t[:text],
        t[:stacktrace],
        t[:platform_id],
        t[:application_id],
        t[:stop].minimum.as('first_occurrence_at'),
        t[:stop].maximum.as('last_occurrence_at'),
        t[Arel.star].count.as('count'),
        Arel::Nodes::NamedFunction.new('array_agg', [t[:id]]).as('ids')
      ).group(
        t[:type],
        t[:text],
        t[:stacktrace],
        t[:platform_id],
        t[:application_id]
      ).order(t[:stop].maximum.desc)
    end
    # rubocop:enable all

    alias t arel_table
  end
end
