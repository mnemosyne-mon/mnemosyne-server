# frozen_string_literal: true

class Activity < ApplicationRecord
  attribute :id, :uuid
  attribute :platform_id, :uuid

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
