# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Mnemosyne::Heatmap::TimeSeries do
  let(:kwargs) { {} }
  let(:series) { described_class.new(**kwargs) }
  let(:time) { Time.zone.local(2017, 5, 30, 14, 46, 7.4647384) }

  around(:each) {|ex| Timecop.freeze(&ex) }

  describe '#initialize' do
  end

  describe '#start' do
    subject { series.start }

    context 'with start given' do
      let(:kwargs) { {start: time} }

      it 'is aligned to last minute' do
        is_expected.to eq Time.zone.local(2017, 5, 30, 14, 46, 0)
      end
    end

    context 'with stop and duration given' do
      let(:kwargs) { {stop: time, duration: 1.hour} }

      it 'is <duration> before <stop> aligned to last minute' do
        is_expected.to eq Time.zone.local(2017, 5, 30, 13, 46, 0)
      end
    end
  end

  describe '#stop' do
    subject { series.stop }

    context 'with stop given' do
      let(:kwargs) { {stop: time} }

      it 'is aligned to last minute' do
        is_expected.to eq Time.zone.local(2017, 5, 30, 14, 46, 0)
      end
    end

    context 'with start and duration given' do
      let(:kwargs) { {start: time, duration: 1.hour} }

      it 'is <duration> after <start> aligned to last minute' do
        is_expected.to eq Time.zone.local(2017, 5, 30, 15, 46, 0)
      end
    end
  end

  describe '#duration' do
    subject { series.duration }
    let(:duration) { 6.hours }

    context 'with duration given' do
      let(:kwargs) { {duration: duration} }

      it { is_expected.to eq duration }
    end

    context 'with start and stop given' do
      let(:kwargs) do
        {
          start: Time.zone.local(2017, 5, 30, 9, 46, 0),
          stop: Time.zone.local(2017, 5, 30, 15, 46, 0)
        }
      end

      it { is_expected.to eq 6.hours }
    end
  end

  describe '#size' do
    subject { series.size }
    let(:size) { 160 }

    context 'with size given' do
      let(:kwargs) { {size: size} }

      it { is_expected.to eq size }
    end
  end

  describe '#interval' do
    subject { series.interval }

    context 'is calculated from duration and size (I)' do
      let(:kwargs) { {duration: 1.hour, size: 6} }
      it { is_expected.to eq ::Mnemosyne::Clock.to_tick(10.minutes) }
    end

    context 'is calculated from duration and size (I)' do
      let(:kwargs) { {duration: 1.hour, size: 96} }
      it { is_expected.to eq ::Mnemosyne::Clock.to_tick(37.5.seconds) }
    end
  end

  describe '#at' do
    let(:idx) { 0 }
    let(:kwargs) { {size: 10, stop: time, duration: 1.hour} }
    subject { series.at(idx) }

    it 'returns first bucket' do
      expect(series.at(0).value).to eq series.start
    end

    it 'returns last bucket' do
      expect(series.at(9).last).to eq series.stop
    end

    describe 'out of bounds' do
      it 'negative: raises error' do
        expect { series.at(-1) }.to raise_error IndexError, /out of bounds/
      end

      it 'equal bucket size: raises error' do
        expect { series.at(10) }.to raise_error IndexError, /out of bounds/
      end

      it 'above bucket size: raises error' do
        expect { series.at(11) }.to raise_error IndexError, /out of bounds/
      end
    end
  end
end
