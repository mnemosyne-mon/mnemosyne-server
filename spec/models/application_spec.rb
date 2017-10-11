# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Application, type: :model do
  let(:application) { create :application }

  subject { application }

  describe '#id' do
    subject { super().id }
    it { expect(subject).to be_a ::UUID4 }
  end

  describe '#platform_id' do
    subject { super().platform_id }
    it { expect(subject).to be_a ::UUID4 }
  end
end
