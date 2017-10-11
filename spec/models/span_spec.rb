# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Span, type: :model do
  let(:time) { Time.zone.now }
  let(:span) { create(:span, **attributes) }

  let(:attributes) { {} }

  subject { span }

  describe '#id' do
    subject { super().id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#trace_id' do
    subject { super().trace_id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#platform_id' do
    subject { super().platform_id }
    it { expect(subject).to be_a ::UUID4 }
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
end
