# frozen_string_literal: true

module Server
  module Pipeline
    module Filter
      class Sample
        MOD = (2**122)
        DIV = MOD.to_f.freeze

        def initialize(rate: 1.0, platform: [], keep_errors: true)
          @rate = rate
          @platform = platform
          @keep_errors = keep_errors
        end

        def call(payload)
          if match_platform?(payload) && no_errors?(payload)
            num = (UUID4.try_convert(payload[:transaction]).to_i % MOD) / DIV
            return if num > @rate
          end

          yield(payload)
        end

        private

        def match_platform?(payload)
          return true if @platform.empty?

          @platform.include?(payload[:platform])
        end

        def no_errors?(payload)
          return true unless @keep_errors

          payload[:errors].blank?
        end
      end
    end
  end
end
