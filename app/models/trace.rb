# frozen_string_literal: true
class Trace < ApplicationRecord
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
    span = spans.where("name ILIKE 'app.controller.%'").order(start: :desc).take

    return span.title if span

    name
  end

  def full_title
    "#{app_name}: #{title}"
  end
end
