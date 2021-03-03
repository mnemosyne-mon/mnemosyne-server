# frozen_string_literal: true

require 'rails_helper'
require 'server/pipeline'

RSpec.describe ::Server::Pipeline::Filter::NullOrigin do
  it 'does yield on source traces' do
    expect do |b|
      described_class.call({origin: nil}, &b)
    end.to yield_control
  end

  it 'does yield on non-null origin traces' do
    expect do |b|
      described_class.call({origin: '982bcc63-8128-4eb2-9f44-9830964300cf'}, &b)
    end.to yield_control
  end

  it 'does not yield on null origin traces' do
    expect do |b|
      described_class.call({origin: '00000000-0000-0000-0000-000000000000'}, &b)
    end.not_to yield_control
  end
end
