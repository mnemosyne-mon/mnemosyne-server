# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::ActiveSupport::Duration do
  TEST_CASES = {
    '1' => {seconds: 1},
    '1s' => {seconds: 1},
    '1m' => {minutes: 1},
    '1h' => {hours: 1},
    '1d' => {days: 1},

    '25' => {seconds: 25},
    '25s' => {seconds: 25},
    '25m' => {minutes: 25},
    '12h' => {hours: 12},
    '15d' => {weeks: 2, days: 1},

    # fractions
    '1ms' => {seconds: 0.001},
    '1us' => {seconds: 0.000001},
    '1ns' => {seconds: 0.000000001},

    # combinations
    '1d5m' => {days: 1, minutes: 5},
    '5m30s' => {minutes: 5, seconds: 30},

    # fractions
    '2.5m' => {minutes: 2, seconds: 30},
    '1d 2.5h' => {days: 1, hours: 2, minutes: 30},
    '0.125s' => {seconds: 0.125},

    # whitespace
    '  4m3s ' => {minutes: 4, seconds: 3},
    "\t4d 1m1s" => {days: 4, minutes: 1, seconds: 1}
  }.freeze

  let(:fn) { described_class.method(:parse_string) }

  describe '.parse_string' do
    TEST_CASES.each_pair do |value, result|
      it "parses #{value.inspect}" do
        expect(fn.call(value).parts).to eq result
      end
    end
  end
end
