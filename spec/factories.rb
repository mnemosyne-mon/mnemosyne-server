# frozen_string_literal: true

FactoryGirl.define do # rubocop:disable BlockLength
  factory :platform do
    sequence(:name) {|n| "platform/#{n}" }
  end

  factory :application do
    sequence(:title) {|n| "Spec Application ##{n}" }
    sequence(:name) {|n| "application/#{n}" }
    association :platform
  end

  factory :activity do
    association :platform
  end

  factory :trace do
    start { Time.zone.now - 2.seconds }
    stop { Time.zone.now }
    name 'mnemosyne.test.trace'
    hostname 'host-0'

    association :application
    association :activity

    after(:build) do |trace|
      trace.platform = trace.activity.platform
    end

    trait :w_spans do
      after(:create) do |trace|
        (4 + rand(30)).times do |i|
          interval = [
            trace.start + Rational(rand(trace.duration), 1_000_000_000),
            trace.start + Rational(rand(trace.duration), 1_000_000_000)
          ]

          create :span,
            trace: trace,
            start: interval.min,
            stop: interval.max,
            meta: {index: i}
        end
      end
    end
  end

  factory :span do
    start { Time.zone.now }
    stop { Time.zone.now }
    name 'mnemosyne.test.span'

    association :trace

    after(:build) do |span|
      span.platform_id = span.trace.platform_id
    end
  end
end
