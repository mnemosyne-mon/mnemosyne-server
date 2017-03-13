# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Trace, type: :model do
  let(:time) { Time.zone.now }

  describe '#start' do
    it 'saves nanosecond datetimes' do
      create :trace, start: time

      expect(Trace.first.start).to eq time
    end

    it 'saves nanoseconds' do
      create :trace, start: ::Mnemosyne::Clock.to_tick(time)

      expect(Trace.first.start).to eq time
    end
  end

  describe '#stop' do
    it 'saves nanosecond datetimes' do
      create :trace, stop: time

      expect(Trace.first.stop).to eq time
    end

    it 'saves nanoseconds' do
      create :trace, stop: ::Mnemosyne::Clock.to_tick(time)

      expect(Trace.first.stop).to eq time
    end
  end

  describe '#duration' do
    it 'returns duration in nanoseconds' do
      create :trace, start: time, stop: time + Rational(5000, 1_000_000_000)

      expect(Trace.first.duration).to eq 5000
    end
  end
end
