# frozen_string_literal: true

class Trace < ApplicationRecord
  include Duration

  attribute :start, ::Mnemosyne::Types::PreciseDateTime.new
  attribute :stop, ::Mnemosyne::Types::PreciseDateTime.new

  attribute :id, ::Mnemosyne::Types::UUID4.new
  attribute :origin_id, ::Mnemosyne::Types::UUID4.new
  attribute :activity_id, ::Mnemosyne::Types::UUID4.new

  has_many :spans, -> { order('start') }

  belongs_to :application
  belongs_to :activity

  def app_name
    return application.name if application.name.present?

    application.original_name
  end

  def title
    span = spans
      .sort_by(&:start)
      .reverse
      .find {|s| s.name =~ /^app\.controller\./ }

    return span.title if span

    name
  end

  def full_title
    "#{app_name}: #{title}"
  end
end
