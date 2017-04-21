# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :traces
  belongs_to :platform

  class << self
    def fetch(ident)
      find_by(id: ident) || find_or_create_by!(original_name: ident)
    end
  end
end
