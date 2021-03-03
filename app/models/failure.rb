# frozen_string_literal: true

class Failure < ApplicationRecord
  self.primary_key = 'id'
  self.inheritance_column = '__no_column'

  attribute :id, :uuid
  attribute :trace_id, :uuid
  attribute :platform_id, :uuid
  attribute :application_id, :uuid

  validates :type, presence: true
  validates :stop, presence: true
  validates :hostname, presence: true

  belongs_to :trace
  belongs_to :platform
  belongs_to :application

  def stacktrace=(stacktrace)
    self[:stacktrace] = Array(stacktrace).map {|sl| sl_conv(sl) }.reject(&:nil?)
  end

  private

  def sl_conv(stackline)
    return nil unless stackline.respond_to?(:[])

    {
      file: stackline[:file].to_s,
      line: stackline[:line].to_i,
      call: stackline[:call].to_s
    }
  end
end
