class Application < ApplicationRecord
  has_many :traces

  class << self
    def fetch(ident)
      by_id = where(id: ident)
      return by_id.take! if by_id.any?

      find_or_create_by! original_name: ident
    end
  end
end
