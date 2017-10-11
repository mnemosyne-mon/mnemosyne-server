# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trace, type: :model do
  let(:time) { Time.zone.now }
  let(:trace) { create(:trace, **attributes) }

  let(:attributes) { {} }

  subject { trace }

  describe '#id' do
    subject { super().id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#platform_id' do
    subject { super().platform_id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#activity_id' do
    subject { super().platform_id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#application_id' do
    subject { super().platform_id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#platform' do
    it 'equals activity platform' do
      expect(trace.platform).to eq trace.activity.platform
    end
  end

  describe '#start' do
    let(:attributes) { {start: time} }
    subject { super().start }

    it 'saves nanoseconds' do
      expect(subject).to eq time
    end
  end

  describe '#stop' do
    let(:attributes) { {stop: time} }
    subject { super().stop }

    it 'saves nanoseconds' do
      expect(subject).to eq time
    end
  end

  describe '#duration' do
    let(:attributes) do
      {start: time, stop: time + Rational(5000, 1_000_000_000)}
    end

    subject { super().duration }

    it 'returns duration in nanoseconds' do
      expect(subject).to eq 5000
    end
  end

  describe '<class>' do
    subject { Trace }

    describe '.retention' do
      let(:period) { ::ActiveSupport::Duration.parse('P30D') }
      let(:time) { Time.zone.now }
      let(:tlimit) { time - period }

      subject { super().retention(period, time) }

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
end
