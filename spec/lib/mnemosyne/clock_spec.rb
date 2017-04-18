# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Mnemosyne::Clock do
  let(:tick) { 1_492_522_002_637_612_303 }
  let(:time) { Time.at(Rational(tick, 1_000_000_000)).utc }

  describe '.to_tick' do
    it 'returns nanosecond-precise time stamp' do
      expect(::Mnemosyne::Clock.to_tick(time)).to eq(tick)
    end
  end

  describe '.to_time' do
    subject { ::Mnemosyne::Clock.to_time(tick) }

    it 'returns nanosecond-precise time' do
      expect(subject.to_i).to eq 1_492_522_002
      expect(subject.nsec).to eq 637_612_303
    end

    it 'returns time in local time zone' do
      expect(subject.zone).to eq time.localtime.zone
    end
  end
end
