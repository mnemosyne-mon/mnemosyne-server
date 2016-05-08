require 'rails_helper'

RSpec.describe Trace, type: :model do
  let(:time) { Time.zone.now }

  describe '#start' do
    it 'saves nanoseconds' do
      Trace.create! start: time

      expect(Trace.first.start).to eq time
    end
  end

  describe '#stop' do
    it 'saves nanoseconds' do
      Trace.create! stop: time

      expect(Trace.first.stop).to eq time
    end
  end

  describe '#duration' do
    it 'returns duration in nanoseconds' do
      Trace.create! start: time, stop: time + Rational(5000, 1_000_000_000)

      expect(Trace.first.duration).to eq 5000
    end
  end
end
