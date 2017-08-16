# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Server::Pipeline::Rails::ActionController do
  let(:payload) do
    {
      span: [{
        name: 'example.trace.mnemosyne'
      }, {
        name: 'app.controller.request.rails',
        meta: {
          controller: 'ApplicationController',
          action: 'index',
          format: 'json'
        }
      }]
    }
  end

  let(:el) { described_class }

  subject { el.call(payload) {|env| return env } }

  it 'extracts controller information' do
    expect(subject[:meta]).to eq \
      controller: 'ApplicationController',
      action: 'index',
      format: 'json'
  end
end
