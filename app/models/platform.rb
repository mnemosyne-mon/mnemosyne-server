# frozen_string_literal: true

class Platform < ApplicationRecord
  attribute :id, ::Mnemosyne::Types::UUID4.new

  validates :name, presence: true

  has_many :activities
  has_many :applications

  def title
    if (title = super).present?
      title
    else
      name
    end
  end

  class << self
    def acquire(name)
      find_or_create_by name: name
    end
  end
end
