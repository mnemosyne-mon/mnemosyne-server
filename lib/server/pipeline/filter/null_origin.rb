# frozen_string_literal: true

module Server
  module Pipeline
    module Filter
      module NullOrigin
        NULL_UUID = '00000000-0000-0000-0000-000000000000'

        def call(payload)
          return if payload[:origin] == NULL_UUID

          yield(payload)
        end

        module_function :call
      end
    end
  end
end
