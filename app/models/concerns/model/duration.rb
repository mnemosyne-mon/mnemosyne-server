# frozen_string_literal: true

module Model
  module Duration
    def duration
      start = ::Server::Clock.to_tick self.start
      stop  = ::Server::Clock.to_tick self.stop

      stop - start
    end
  end
end
