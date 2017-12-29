# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::Server::Pipeline do
  let(:pipeline) { described_class }

  subject { pipeline.call(1) }

  it 'calls pipeline processors in order' do
    expect(::Server::Pipeline::Metadata::Grape::Endpoint).to \
      receive(:call).with(1).and_yield(2)

    expect(::Server::Pipeline::Metadata::Rails::ActionController).to \
      receive(:call).with(2).and_yield(3)

    expect(::Server::Pipeline::Metadata::Rails::ActiveJob).to \
      receive(:call).with(3).and_yield(4)

    expect_any_instance_of(::Server::Builder).to \
      receive(:call).with(4)

    subject
  end
end
