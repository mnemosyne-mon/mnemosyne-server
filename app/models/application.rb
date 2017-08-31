# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :traces
  belongs_to :platform

  upsert_keys %i[name platform_id]

  def name
    super || original_name
  end
end
