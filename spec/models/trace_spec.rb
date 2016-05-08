require 'rails_helper'

RSpec.describe Trace, type: :model do
  describe '#start' do
    it 'saves nanoseconds' do
      time  = Time.zone.now
      Trace.create! start: time

      trace = Trace.first
      expect(trace.start).to eq time
    end
  end
end
