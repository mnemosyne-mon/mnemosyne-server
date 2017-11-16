# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Server::Pipeline::Metadata::Grape::Endpoint do
  let(:payload) do
    {
      span: [{
        name: 'example.trace.mnemosyne'
      }, {
        name: 'app.controller.request.grape',
        meta: {
          endpoint: 'API::V2::Endpoint',
          format: 'json'
        }
      }]
    }
  end

  subject { described_class.call(payload) {|env| return env } }

  it 'extracts endpoint information' do
    expect(subject[:meta]).to eq \
      controller: 'API::V2::Endpoint',
      format: 'json'
  end
end
