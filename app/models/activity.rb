# frozen_string_literal: true

class Activity < ApplicationRecord
  attribute :id, ::Server::Types::UUID4.new

  attribute :platform_id, ::Server::Types::UUID4.new

  has_many :traces
  belongs_to :platform

  class << self
    def fetch(uuid)
      find_or_create_by id: uuid
    end
  end
end
