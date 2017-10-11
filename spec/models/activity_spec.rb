# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Activity, type: :model do
  let(:activity) { create :activity }

  subject { activity }

  describe '#id' do
    subject { super().id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#platform_id' do
    subject { super().platform_id }
    it { expect(subject).to be_a ::UUID4 }
  end
end
