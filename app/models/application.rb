# frozen_string_literal: true

class Application < ApplicationRecord
  attribute :id, :uuid
  attribute :platform_id, :uuid

  has_many :traces, dependent: :destroy
  belongs_to :platform

  upsert_keys %i[name platform_id]

  def name
    super || original_name
  end

  class << self
    def resolve(value)
      if (uuid = UUID4.try_convert(value))
        find_by(id: uuid)
      else
        find_by(name: value.to_s)
      end
    end

    def fetch(name:, platform:)
      platform = platform.id if platform.respond_to?(:id)

      # We do need `upsert` here for performance reasons.
      # rubocop:disable Rails/SkipsModelValidations
      find_by(name: name, platform_id: platform) ||
        upsert(name: name, platform_id: platform)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
