# frozen_string_literal: true

require "rails_helper"
require "server/pipeline"

RSpec.describe Server::Pipeline::Metadata::Rails::ActionController do
  subject(:call) { el.call(payload) {|env| return env } }

  let(:payload) do
    {
      span: [{
        name: "example.trace.mnemosyne",
      }, {
        name: "app.controller.request.rails",
        meta: {
          controller: "ApplicationController",
          action: "index",
          format: "json",
        },
      },],
    }
  end

  let(:el) { described_class }

  it "extracts controller information" do
    expect(call[:meta]).to eq \
      controller: "ApplicationController",
      action: "index",
      format: "json"
  end
end
