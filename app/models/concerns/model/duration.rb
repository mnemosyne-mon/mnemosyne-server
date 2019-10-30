# frozen_string_literal: true

module Model
  module Duration
    def duration
      start = ::Mnemosyne::Clock.to_tick self.start
      stop  = ::Mnemosyne::Clock.to_tick self.stop

      stop - start
    end
  end
end
