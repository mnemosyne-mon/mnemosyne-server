# frozen_string_literal: true

require "rails_helper"

RSpec.describe FailureGroup do
  subject { described_class.first }

  let(:platform) { create(:platform) }
  let(:application) { create(:application, platform:) }

  let(:first_stop) { Server::Clock.to_time(1_507_739_483_732_049_213) }
  let(:last_stop) { Server::Clock.to_time(1_507_739_558_924_858_253) }

  let!(:failures) do
    Array.new(2).each_with_index.map do |_, i|
      create(:failure,
        type: "Error::Class",
        text: "Error class message text",
        stop: i.zero? ? first_stop : last_stop,
        platform:,
        application:,)
    end
  end

  before do
    # Preconditions

    # Failure traces must belong to same group
    expect(failures.map(&:platform_id).uniq).to eq [platform.id]
    expect(failures.map(&:application_id).uniq).to eq [application.id]

    # Both must have different traces
    expect(failures.map(&:trace_id).uniq.size).to eq 2

    failures.map(&:trace).tap do |traces|
      # Both traces must belong same application
      expect(traces.map(&:application_id).uniq).to eq [application.id]

      # Both traces must have different activities
      expect(traces.map(&:activity_id).uniq.size).to eq 2
    end
  end

  describe "#type" do
    subject { super().type }

    it { is_expected.to eq "Error::Class" }
  end

  describe "#text" do
    subject { super().text }

    it { is_expected.to eq "Error class message text" }
  end

  describe "#count" do
    subject { super().count }

    it { is_expected.to eq 2 }
  end

  describe "#first_occurrence_at" do
    subject { super().first_occurrence_at }

    it { is_expected.to eq Server::Clock.to_time(1_507_739_483_732_049_000) }
  end

  describe "#last_occurrence_at" do
    subject { super().last_occurrence_at }

    it { is_expected.to eq Server::Clock.to_time(1_507_739_558_924_858_000) }
  end

  describe "#platform_id" do
    subject { super().platform_id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#application_id" do
    subject { super().application_id }

    it { is_expected.to be_a UUID4 }
  end
end
