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
    let(:interval) { 25_000_000 }

    context 'with interval given' do
      let(:kwargs) { {interval: interval} }

      it { is_expected.to eq interval }
    end
  end

  describe '#at' do
    let(:idx) { 0 }
    let(:kwargs) { {interval: 10, size: 10} }
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
