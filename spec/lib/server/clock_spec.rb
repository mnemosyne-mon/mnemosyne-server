# frozen_string_literal: true

require "spec_helper"
require "server/clock"

RSpec.describe Server::Clock do
  let(:tick) { 1_492_522_002_637_612_303 }
  let(:time) { Time.at(Rational(tick, 1_000_000_000)).utc }

  describe ".to_tick" do
    subject(:result) { described_class.to_tick(time) }

    context "with time" do
      it "returns nanosecond-precise time stamp" do
        expect(result).to eq(tick)
      end
    end

    context "with duration" do
      let(:time) { ActiveSupport::Duration.seconds(30.75) }

      it { is_expected.to eq 30_750_000_000 }
    end
  end

  describe ".to_time" do
    subject(:result) { described_class.to_time(tick) }

    it "returns nanosecond-precise time" do
      expect(result.to_i).to eq 1_492_522_002
      expect(result.nsec).to eq 637_612_303
    end

    it "returns time in local time zone" do
      expect(result.zone).to eq time.localtime.zone
    end
  end
end
