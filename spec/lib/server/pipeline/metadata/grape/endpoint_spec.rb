# frozen_string_literal: true

require "rails_helper"
require "server/pipeline"

RSpec.describe Server::Pipeline::Metadata::Grape::Endpoint do
  subject(:call) { described_class.call(payload) {|env| return env } }

  let(:payload) do
    {
      span: [{
        name: "example.trace.mnemosyne",
      }, {
        name: "app.controller.request.grape",
        meta: {
          endpoint: "API::V2::Endpoint",
          format: "json",
        },
      },],
    }
  end

  it "extracts endpoint information" do
    expect(call[:meta]).to eq \
      controller: "API::V2::Endpoint",
      format: "json"
  end
end
