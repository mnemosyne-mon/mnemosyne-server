# frozen_string_literal: true

require 'rails_helper'
require 'server/pipeline'

RSpec.describe ::Server::Pipeline::Filter::Sample do
  let(:payload) do
    {
      platform: 'test',
      transaction: 'a6616ba8-a07f-4812-86df-a3c9e159ee86'
    }
  end

  def mk_call(extra)
    ->(b) { filter.call(payload.merge(extra), &b) }
  end

  describe 'rate' do
    let(:filter) { described_class.new(rate: 0.5) }

    it 'does filter matching traces' do
      expect(mk_call({
        transaction: '035c9059-238b-4f9e-9505-bc73f2ee39ed'
      })).not_to yield_control
    end

    it 'does not filter non-matching traces' do
      expect(mk_call({
        transaction: 'cca7e687-58d8-4fc9-a47b-5c623897076d'
      })).to yield_control
    end

    it 'does not filter traces with errors even if they match' do
      expect(mk_call({
        transaction: '035c9059-238b-4f9e-9505-bc73f2ee39ed',
        errors: [{
          type: 'RuntimeError',
          text: 'error message',
          stacktrace: [{
            file: '(pry)',
            line: '2',
            call: 'm',
            raw: "(pry):2:in `m'"
          }]
        }]
      })).to yield_control
    end
  end

  describe 'platform filter' do
    let(:filter) { described_class.new(rate: 0, platform: %w[test1 test2]) }

    it 'does filter traces of matching platforms' do
      expect(mk_call({platform: 'test1'})).not_to yield_control
      expect(mk_call({platform: 'test2'})).not_to yield_control
    end

    it 'does not filter traces of non-matching platforms' do
      expect(mk_call({platform: 'other'})).to yield_control
    end
  end

  describe 'keep_errors option' do
    let(:filter) { described_class.new(rate: 0.5, keep_errors: false) }

    it 'does again filter matching traces with errors' do
      expect(mk_call({
        transaction: '035c9059-238b-4f9e-9505-bc73f2ee39ed',
        errors: [{
          type: 'RuntimeError',
          text: 'error message',
          stacktrace: [{
            file: '(pry)',
            line: '2',
            call: 'm',
            raw: "(pry):2:in `m'"
          }]
        }]
      })).not_to yield_control
    end
  end
end
