# frozen_string_literal: true

class Activity < ApplicationRecord
  attribute :id, ::Server::Types::UUID4.new

  attribute :platform_id, ::Server::Types::UUID4.new

  has_many :traces
  belongs_to :platform

  upsert_keys %i[id]

  class << self
    def fetch(id:, platform:)
      platform = platform.id if platform.respond_to?(:id)

      find_by(id: id) || upsert(id: id, platform_id: platform)
    end
  end
end
