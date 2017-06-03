# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Mnemosyne::Builder do
  let(:payload) { {} }
  let(:builder) { described_class.new(payload) }

  subject { builder.create! }

  context 'with payload (I)' do
    let(:payload) do
      {
        uuid: 'cd25562f-42e6-48e6-9f3b-08632da38921',
        origin: '38653828-54e2-4c5a-ab4d-45fa4e24ef79',
        transaction: '4c6d1d78-3eec-4ac8-9720-80baff80e1f8',
        application: 'Mnemosyne/Application',
        platform: 'my-platform',
        hostname: 'services-1',
        name: 'example.trace.mnemosyne',
        start: 0,
        stop: 1_000_000_000,
        span: [{
          uuid: 'd9a6f0f0-eff4-4f43-af75-9d15ba2de93c',
          name: 'example.span.mnemosyne',
          start: 100_000_000,
          stop: 200_000_000
        }]
      }
    end

    let(:trace) { Trace.find payload.fetch(:uuid) }

    it 'creates activity' do
      expect { subject }.to change(Activity, :count).from(0).to(1)
    end

    it 'creates platform' do
      expect { subject }.to change(Platform, :count).from(0).to(1)
    end

    it 'creates application' do
      expect { subject }.to change(Application, :count).from(0).to(1)
    end

    it 'creates trace' do
      expect { subject }.to change(Trace, :count).from(0).to(1)
    end

    it 'creates span' do
      expect { subject }.to change(Span, :count).from(0).to(1)
    end

    describe 'platform' do
      before { builder.create! }
      subject { trace.platform }

      example 'name equals payload value' do
        expect(subject.name).to eq 'my-platform'
      end
    end

    describe 'activity' do
      before { builder.create! }
      subject { trace.activity }

      example 'UUID equals payload value' do
        expect(subject.id).to eq '4c6d1d78-3eec-4ac8-9720-80baff80e1f8'
      end

      example 'correct platform is associated' do
        expect(subject.platform.name).to eq 'my-platform'
      end
    end

    describe 'application' do
      before { builder.create! }
      subject { trace.application }

      example 'original name equals payload value' do
        expect(subject.name).to eq 'Mnemosyne/Application'
      end

      example 'correct platform is associated' do
        expect(subject.platform.name).to eq 'my-platform'
      end
    end

    describe 'trace' do
      before { builder.create! }
      subject { trace }

      example 'UUID equals payload value' do
        expect(subject.id).to eq 'cd25562f-42e6-48e6-9f3b-08632da38921'
      end

      example 'origin equals payload value' do
        expect(subject.origin_id).to eq '38653828-54e2-4c5a-ab4d-45fa4e24ef79'
      end

      example 'name equals payload value' do
        expect(subject.name).to eq 'example.trace.mnemosyne'
      end

      example 'start time equals payload value' do
        expect(subject.start).to eq Time.at(0).utc
      end

      example 'stop time equals payload value' do
        expect(subject.stop).to eq Time.at(1).utc
      end

      example 'hostname equals payload value' do
        expect(subject.hostname).to eq 'services-1'
      end

      example 'correct activity is associated' do
        expect(subject.activity.id).to eq '4c6d1d78-3eec-4ac8-9720-80baff80e1f8'
      end
    end

    describe 'span' do
      before { builder.create! }
      subject { trace.spans.first }

      example 'UUID equals payload value' do
        expect(subject.id).to eq 'd9a6f0f0-eff4-4f43-af75-9d15ba2de93c'
      end

      example 'name equals payload value' do
        expect(subject.name).to eq 'example.span.mnemosyne'
      end

      example 'start time equals payload value' do
        expect(subject.start).to eq Time.at(Rational(1, 10)).utc
      end

      example 'stop time equals payload value' do
        expect(subject.stop).to eq Time.at(Rational(2, 10)).utc
      end

      example 'correct trace is associated' do
        expect(subject.trace.id).to eq 'cd25562f-42e6-48e6-9f3b-08632da38921'
      end
    end
  end
end
