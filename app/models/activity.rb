# frozen_string_literal: true

class Activity < ApplicationRecord
  attribute :id, ::Mnemosyne::Types::UUID4.new

  has_many :traces

  class << self
    def fetch(uuid)
      find_or_create_by id: uuid
    end
  end
end
