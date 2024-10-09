# frozen_string_literal: true

require "spec_helper"

RSpec.describe Platform, type: :model do
  let(:platform) { create(:platform) }

  describe "#id" do
    subject { platform.id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#retention_period" do
    subject { platform.retention_period }

    it { is_expected.to be_a ActiveSupport::Duration }
  end
end
