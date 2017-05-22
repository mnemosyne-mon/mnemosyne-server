# frozen_string_literal: true

class Application < ApplicationRecord
  has_many :traces
  belongs_to :platform

  def name
    super || original_name
  end

  class << self
    def fetch(ident)
      find_by(id: ident) || find_or_create_by!(name: ident)
    end
  end
end
