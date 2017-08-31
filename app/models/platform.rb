# frozen_string_literal: true

class Platform < ApplicationRecord
  attribute :id, ::Server::Types::UUID4.new
  attribute :retention_period, ::Server::Types::Duration.new

  validates :name, presence: true

  has_many :activities
  has_many :applications
  has_many :traces

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
end
