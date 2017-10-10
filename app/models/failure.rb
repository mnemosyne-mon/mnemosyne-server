# frozen_string_literal: true

class Failure < ApplicationRecord
  self.inheritance_column = '__no_column'

  attribute :id, ::Server::Types::UUID4.new

  validates :type, presence: true
  validates :text, presence: true
  validates :stacktrace, presence: true

  belongs_to :trace
  belongs_to :platform

  def stacktrace=(stacktrace)
    self[:stacktrace] = Array(stacktrace).map(&method(:sl_conv)).reject(&:nil?)
  end

  private

  def sl_conv(sl)
    return nil unless sl.respond_to?(:[])

    {
      file: sl[:file].to_s,
      line: sl[:line].to_i,
      call: sl[:call].to_s
    }
  end
end
