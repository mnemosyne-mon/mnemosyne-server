# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Mnemosyne::Payload do
  let(:payload) { {payload: true} }
  let(:kwargs)  { {} }

  describe '.new' do
    it 'dispatches to matching payload version (I)' do
      expect(::Mnemosyne::Payload::V1).to receive(:new).with(payload, kwargs)

      ::Mnemosyne::Payload.new(payload, **kwargs)
    end
  end

  describe 'Types' do
    describe 'Strict::UUID' do
      subject { ::Dry::Types['strict.uuid'] }

      it 'converts UUID to object' do
        expect(subject['cd4ea0e2-3d0d-4fb2-823e-5765e7b6783b']).to eq \
          UUID4.new('cd4ea0e2-3d0d-4fb2-823e-5765e7b6783b')
      end

      it 'raises on nil' do
        expect { subject[nil] }.to raise_error TypeError, /Invalid UUID/
      end

      it 'raises on invalid string' do
        expect { subject['abc'] }.to raise_error TypeError, /Invalid UUID/
      end

      it 'raises on integer' do
        expect { subject[5] }.to raise_error TypeError, /Invalid UUID/
      end
    end

    describe 'Strict::UUID' do
      subject { ::Dry::Types['uuid'] }

      it 'converts UUID to object' do
        expect(subject['cd4ea0e2-3d0d-4fb2-823e-5765e7b6783b']).to eq \
          UUID4.new('cd4ea0e2-3d0d-4fb2-823e-5765e7b6783b')
      end

      it 'raises on nil' do
        expect(subject[nil]).to eq nil
      end

      it 'raises on invalid string' do
        expect(subject['abc']).to eq nil
      end

      it 'raises on integer' do
        expect(subject[5]).to eq nil
      end
    end
  end
end
