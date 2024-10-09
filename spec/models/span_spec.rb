# frozen_string_literal: true

require "rails_helper"

RSpec.describe Span, type: :model do
  subject(:span) { create(:span, **attributes) }

  let(:time) { Time.zone.now }
  let(:attributes) { {} }

  describe "#id" do
    subject { span.id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#trace_id" do
    subject { span.trace_id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#platform_id" do
    subject { span.platform_id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#start" do
    subject(:start) { span.start }

    let(:attributes) { {start: time} }

    it "saves nanoseconds" do
      expect(start).to eq time
    end
  end

  describe "#stop" do
    subject(:stop) { span.stop }

    let(:attributes) { {stop: time} }

    it "saves nanoseconds" do
      expect(stop).to eq time
    end
  end

  describe "#duration" do
    subject(:duration) { span.duration }

    let(:attributes) do
      {start: time, stop: time + Rational(5000, 1_000_000_000)}
    end

    it "returns duration in nanoseconds" do
      expect(duration).to eq 5000
    end
  end
end
