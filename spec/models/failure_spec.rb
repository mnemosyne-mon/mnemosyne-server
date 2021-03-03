# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Failure, type: :model do
  subject { failure }

  let(:failure) { create(:failure, **attributes) }
  let(:attributes) { {} }

  describe '<factory>' do
    let(:trace) { failure.trace }

    describe '#platform' do
      subject { failure.platform.id }

      it { is_expected.to eq trace.platform.id }
    end

    describe '#application' do
      subject { failure.application.id }

      it { is_expected.to eq trace.application.id }
    end

    context 'with platform attribute' do
      let(:platform) { create :platform }
      let(:attributes) { {platform: platform} }

      it { expect { failure }.to change(Platform, :count).from(0).to(1) }

      it { expect(failure.platform.id).to eq platform.id }
      it { expect(trace.platform.id).to eq platform.id }
    end

    context 'with application attribute' do
      let(:application) { create :application }
      let(:attributes) { {application: application} }

      it { expect { failure }.to change(Application, :count).from(0).to(1) }

      it { expect(failure.application.id).to eq application.id }
      it { expect(trace.application.id).to eq application.id }
    end
  end

  describe '#id' do
    subject { super().id }

    it { is_expected.to be_a ::UUID4 }
  end

  describe '#trace_id' do
    subject { super().trace_id }

    it { is_expected.to be_a ::UUID4 }
  end

  describe '#platform_id' do
    subject { super().platform_id }

    it { is_expected.to be_a ::UUID4 }
  end

  describe '#application_id' do
    subject { super().application_id }

    it { is_expected.to be_a ::UUID4 }
  end
end
