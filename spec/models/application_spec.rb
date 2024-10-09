# frozen_string_literal: true

require "rails_helper"

RSpec.describe Application, type: :model do
  subject(:application) { create(:application) }

  describe "#id" do
    subject { application.id }

    it { is_expected.to be_a UUID4 }
  end

  describe "#platform_id" do
    subject { application.platform_id }

    it { is_expected.to be_a UUID4 }
  end
end
