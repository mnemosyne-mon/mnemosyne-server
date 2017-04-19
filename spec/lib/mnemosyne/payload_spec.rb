# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Mnemosyne::Payload do
  let(:payload) { {payload: true} }
  let(:kwargs)  { {} }
  let(:subject) { ::Mnemosyne::Payload.new(payload, **kwargs) }

  describe '.new' do
    it 'dispatches to matching payload version (I)' do
      expect(::Mnemosyne::Payload::V1).to receive(:new).with(payload)

      ::Mnemosyne::Payload.new(payload, **kwargs)
    end

    context 'with invalid payload (I)' do
      let(:payload) { {} }

      it 'raises TypeError' do
        expect { subject }.to raise_error \
          TypeError, /application is missing/
      end
    end

    context 'with invalid payload (II)' do
      let(:payload) { {application: nil} }

      it 'raises TypeError' do
        expect { subject }.to raise_error \
          TypeError, /Must not be blank/
      end
    end

    context 'with invalid payload (III)' do
      let(:payload) { {application: ''} }

      it 'raises TypeError' do
        expect { subject }.to raise_error \
          TypeError, /Must not be blank/
      end
    end

    context 'with parses and cleans valid payload (I)' do
      let(:payload) do
        {
          application: ' Rails/Application  ',
          platform: "default\r\n",
          activity: '768416c3-9246-4206-99ce-71c9bdbeda3f',
          uuid: 'ef89fab2-cfe6-4c1d-9b23-4f977349efc6',
          name: 'app.web.request.rack',
          start: 1492599143552673058,
          stop: 1492599151622173813,
          span: [{
            uuid: '25ed4c6a-4123-49ce-9899-da3588772bb8',
            name: 'app.web.controller.rails',
            start: 0,
            stop: 0
          }]
        }
      end

      it 'contains frozen payload data' do
        expect(subject.application).to eq 'Rails/Application'
        expect(subject.platform).to eq 'default'

        expect(subject.activity).to eq \
          UUID4('768416c3-9246-4206-99ce-71c9bdbeda3f')
        expect(subject.uuid).to eq \
          UUID4('ef89fab2-cfe6-4c1d-9b23-4f977349efc6')

        expect(subject.name).to eq 'app.web.request.rack'

        expect(subject.start).to eq \
          Time.iso8601('2017-04-19T12:52:23.552673058+02:00')
        expect(subject.stop).to eq \
          Time.iso8601('2017-04-19T12:52:31.622173813+02:00')

        span = subject.span.first

        expect(span.uuid).to eq UUID4('25ed4c6a-4123-49ce-9899-da3588772bb8')
        expect(span.name).to eq 'app.web.controller.rails'
        expect(span.start).to eq Time.zone.at(0)
        expect(span.stop).to eq Time.zone.at(0)

        expect(subject).to be_frozen
      end
    end
  end

  describe 'Types' do
    describe 'Name' do
      subject { ::Mnemosyne::Payload::Types::Name }

      it 'converts to string' do
        expect(subject[5]).to eq '5'
      end

      it 'strips whitespace' do
        expect(subject[" abc\r\n"]).to eq 'abc'
      end

      it 'raises on nil' do
        expect { subject[nil] }.to raise_error \
          TypeError, /Must not be blank/
      end

      it 'raises raise on blank string' do
        expect { subject["  \r\n"] }.to raise_error \
          TypeError, /Must not be blank/
      end
    end

    describe 'UUID' do
      subject { ::Mnemosyne::Payload::Types::UUID }

      it 'converts UUID to object' do
        expect(subject['cd4ea0e2-3d0d-4fb2-823e-5765e7b6783b']).to eq \
          UUID4.new('cd4ea0e2-3d0d-4fb2-823e-5765e7b6783b')
      end

      it 'raises on nil' do
        expect { subject[nil] }.to raise_error \
          TypeError, /Invalid UUID: nil/
      end

      it 'raises on invalid string' do
        expect { subject['abc'] }.to raise_error \
          TypeError, /Invalid UUID: "abc"/
      end

      it 'raises on integer' do
        expect { subject[5] }.to raise_error \
          TypeError, /Invalid UUID: 5/
      end
    end
  end
end
