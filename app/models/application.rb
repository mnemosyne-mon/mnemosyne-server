# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :traces
  belongs_to :platform

  upsert_keys %i[name platform_id]

  def name
    super || original_name
  end

  class << self
    def fetch(name:, platform:)
      platform = platform.id if platform.respond_to?(:id)

      find_by(name: name, platform_id: platform) ||
        upsert(name: name, platform_id: platform)
    end
  end
end
