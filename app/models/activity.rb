# frozen_string_literal: true

class Activity < ApplicationRecord
  attribute :id, ::Server::Types::UUID4.new

  attribute :platform_id, ::Server::Types::UUID4.new

  has_many :traces
  belongs_to :platform

  upsert_keys %i[id platform_id]
end
