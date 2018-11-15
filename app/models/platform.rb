# frozen_string_literal: true

class Platform < ApplicationRecord
  attribute :id, :uuid
  attribute :retention_period, :interval

  validates :name, presence: true

  has_many :activities, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :traces, dependent: :destroy
  has_many :failures, dependent: :destroy

  upsert_keys %i[name]

  def title
    if (title = super).present?
      title
    else
      name
    end
  end

  def to_param
    name
  end

  class << self
    def fetch(name:)
      find_by(name: name) || upsert(name: name)
    end
  end
end
