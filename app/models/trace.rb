class Trace < ActiveRecord::Base
  include Duration

  attribute :start, ::Mnemosyne::Types::PreciseDateTime.new
  attribute :stop, ::Mnemosyne::Types::PreciseDateTime.new

  has_many :spans, -> { order('start') }

  belongs_to :application

  def app_name
    return application.name if application.name.present?

    application.original_name
  end

  def title
    controller_span = spans.where(name: 'rails.process_action.action_controller')

    if controller_span.any?
      span = controller_span.take
      return "#{span.meta['controller']}##{span.meta['action']}"
    end

    name
  end
end
