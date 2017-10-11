# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FailureGroup, type: :model do
  let(:platform) { create :platform }
  let(:application) { create :application, platform: platform }

  let(:first_stop) { ::Server::Clock.to_time(1507739483732049213) }
  let(:last_stop) { ::Server::Clock.to_time(1507739558924858253) }

  let!(:failures) do
    Array.new(2).each_with_index.map do |_, i|
      create :failure,
        type: 'Error::Class',
        text: 'Error class message text',
        stop: i.zero? ? first_stop : last_stop,
        platform: platform,
        application: application
    end
  end

  let(:failure_group) { FailureGroup.all.first }

  subject { failure_group }

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

      traces.map(&:activity).tap do |activities|
        # Both activities must belong to same platform
        expect(activities.map(&:platform_id).uniq).to eq [platform.id]
      end
    end
  end

  describe '#type' do
    subject { super().type }
    it { expect(subject).to eq 'Error::Class' }
  end

  describe '#text' do
    subject { super().text }
    it { expect(subject).to eq 'Error class message text' }
  end

  describe '#count' do
    subject { super().count }
    it { expect(subject).to eq 2 }
  end

  describe '#first_occurrence_at' do
    subject { super().first_occurrence_at }
    it { expect(subject).to eq first_stop }
  end

  describe '#last_occurrence_at' do
    subject { super().last_occurrence_at }
    it { expect(subject).to eq last_stop }
  end

  describe '#platform_id' do
    subject { super().platform_id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#application_id' do
    subject { super().application_id }
    it { expect(subject).to be_a ::UUID4 }
  end
end
