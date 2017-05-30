# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Mnemosyne::Heatmap::LatencySeries do
  let(:kwargs) { {} }
  let(:series) { described_class.new(**kwargs) }

  describe '#initialize' do
  end

  describe '#start' do
    subject { series.start }

    context 'with start given' do
      let(:kwargs) { {start: 10} }

      it { is_expected.to eq 10 }
    end
  end

  describe '#stop' do
    subject { series.stop }

    context 'with stop given' do
      let(:kwargs) { {stop: 20} }

      it { is_expected.to eq 20 }
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

    context 'is calculated from duration and buckets (I)' do
      let(:kwargs) { {duration: 1.hour, buckets: 6} }
      it { is_expected.to eq ::Mnemosyne::Clock.to_tick(10.minutes) }
    end

    context 'is calculated from duration and buckets (I)' do
      let(:kwargs) { {duration: 1.hour, buckets: 96} }
      it { is_expected.to eq ::Mnemosyne::Clock.to_tick(37.5.seconds) }
    end
  end

  describe '#at' do
    let(:idx) { 0 }
    let(:kwargs) { {buckets: 10, last: time, duration: 1.hour} }
    subject { series.at(idx) }

    it 'returns first bucket' do
      expect(series.at(0).value).to eq series.first
    end

    it 'returns last bucket' do
      expect(series.at(9).last).to eq series.last
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
