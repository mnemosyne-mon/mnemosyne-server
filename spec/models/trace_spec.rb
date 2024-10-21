# frozen_string_literal: true

require "rails_helper"

RSpec.describe Trace do
  subject(:trace) { create(:trace, **attributes) }

  let(:time) { Time.zone.now }
  let(:attributes) { {} }

  describe "#id" do
    subject { trace.id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#origin_id" do
    subject { trace.origin_id }

    let(:attributes) { {origin: create(:span)} }

    it { is_expected.to be_a UUID4 }
  end

  describe "#platform_id" do
    subject { trace.platform_id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#activity_id" do
    subject { trace.activity_id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#application_id" do
    subject { trace.application_id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#start" do
    subject(:start) { trace.start }

    let(:attributes) { {start: time} }

    it "saves nanoseconds" do
      expect(start).to eq time
    end
  end

  describe "#stop" do
    subject(:stop) { trace.stop }

    let(:attributes) { {stop: time} }

    it "saves nanoseconds" do
      expect(stop).to eq time
    end
  end

  describe "#duration" do
    subject(:duration) { trace.duration }

    let(:attributes) do
      {start: time, stop: time + Rational(5000, 1_000_000_000)}
    end

    it "returns duration in nanoseconds" do
      expect(duration).to eq 5000
    end
  end

  describe "<class>" do
    describe ".retention" do
      subject(:traces) { described_class.retention(period, time) }

      let(:period) { ActiveSupport::Duration.parse("P30D") }
      let(:time) { Time.zone.now }
      let(:tlimit) { time - period }

      let!(:tr0) do
        create(:trace, :w_spans, start: tlimit - 30, stop: tlimit - 29.8)
      end

      before do
        create(:trace, :w_spans, start: tlimit - 4, stop: tlimit + 5)
        create(:trace, :w_spans, start: tlimit + 2, stop: tlimit + 4)
      end

      it "scopes traces outside of retention period" do
        expect(traces.pluck(:id)).to contain_exactly(tr0.id)
      end

      context "with stored trace" do
        before do
          create(:trace, :w_spans,
            start: tlimit - 20, stop: tlimit - 10, store: true,)
        end

        it "does not scope stored traces" do
          expect(traces.pluck(:id)).to contain_exactly(tr0.id)
        end
      end
    end

    describe ".latency_above" do
      subject(:traces) { described_class.latency_above(value) }

      let(:value) { "5s" }

      let!(:expected) do
        create(:trace, :w_spans, start: Time.zone.now, stop: Time.zone.now + 10)
      end

      before do
        create(:trace, :w_spans, start: Time.zone.now, stop: Time.zone.now + 4)
        create(:trace, :w_spans, start: Time.zone.now, stop: Time.zone.now + 2)
      end

      it "returns only traces above 5 seconds in length" do
        expect(described_class.count).to eq 3

        expect(traces).to contain_exactly(expected)
      end
    end

    describe ".latency_below" do
      subject(:traces) { described_class.latency_below(value) }

      let(:value) { "5s" }

      let!(:expected) do
        create(:trace, :w_spans, start: Time.zone.now, stop: Time.zone.now + 4)
      end

      before do
        create(:trace, :w_spans, start: Time.zone.now, stop: Time.zone.now + 6)
        create(:trace, :w_spans, start: Time.zone.now, stop: Time.zone.now + 10)
      end

      it "returns only traces above 5 seconds in length" do
        expect(described_class.count).to eq 3

        expect(traces).to contain_exactly(expected)
      end
    end
  end
end
