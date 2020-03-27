# frozen_string_literal: true

module Server
  module Pipeline
    module Filter
      class Sample
        MOD = (2 ** 122).freeze
        DIV = MOD.to_f.freeze

        def initialize(rate: 1.0, platform: [])
          @rate = rate
          @platform = platform
        end

        def call(payload)
          unless ignore?(payload)
            num = (UUID4.try_convert(payload[:transaction]).to_i % MOD) / DIV
            return if num > @rate
          end

          yield(payload)
        end

        private

        def ignore?(payload)
          return false if @platform.empty?
          !@platform.include?(payload[:platform])
        end
      end
    end
  end
end
