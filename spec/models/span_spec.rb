require 'rails_helper'

RSpec.describe Span, type: :model do
  let(:time) { Time.zone.now }

  describe '#start' do
    it 'saves nanoseconds' do
      Span.create! start: time

      expect(Span.first.start).to eq time
    end
  end

  describe '#stop' do
    it 'saves nanoseconds' do
      Span.create! stop: time

      expect(Span.first.stop).to eq time
    end
  end

  describe '#duration' do
    it 'returns duration in nanoseconds' do
      Span.create! start: time, stop: time + Rational(5000, 1_000_000_000)

      expect(Span.first.duration).to eq 5000
    end
  end
end
