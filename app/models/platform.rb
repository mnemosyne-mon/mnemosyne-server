# frozen_string_literal: true

class Platform < ApplicationRecord
  attribute :id, ::Server::Types::UUID4.new
  attribute :retention_period, ::Server::Types::Duration.new

  validates :name, presence: true

  has_many :activities
  has_many :applications
  has_many :traces

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
    def acquire(name)
      find_or_create_by name: name
    end
  end
end
