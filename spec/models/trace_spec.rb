# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trace, type: :model do
  let(:time) { Time.zone.now }
  let(:trace) { build :trace }

  describe '#platform' do
    it 'equals activity platform' do
      expect(trace.platform).to eq trace.activity.platform
    end
  end

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

  describe '.retention' do
    let(:period) { ::ActiveSupport::Duration.parse('P30D') }
    let(:time) { Time.zone.now }
    let(:tlimit) { time - period }

    subject { Trace.retention(period, time) }

    let!(:tr0) do
      create :trace, :w_spans, start: tlimit - 30, stop: tlimit - 29.8
    end

    let!(:tn0) do
      create :trace, :w_spans, start: tlimit - 4, stop: tlimit + 5
    end

    let!(:tn1) do
      create :trace, :w_spans, start: tlimit + 2, stop: tlimit + 4
    end

    it 'scopes traces outside of retention period' do
      expect(subject.pluck(:id)).to match_array [tr0.id]
    end

    context 'with stored trace' do
      let!(:tr1) do
        create :trace, :w_spans,
          start: tlimit - 20, stop: tlimit - 10, store: true
      end

      it 'does not scope stored traces' do
        expect(subject.pluck(:id)).to match_array [tr0.id]
      end
    end
  end
end
