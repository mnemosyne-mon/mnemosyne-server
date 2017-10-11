# frozen_string_literal: true

# rubocop:disable BlockLength
FactoryGirl.define do
  factory :platform do
    sequence(:name) {|n| "platform/#{n}" }
  end

  factory :application do
    transient do
      platform { create :platform }
    end

    sequence(:title) {|n| "Spec Application ##{n}" }
    sequence(:name) {|n| "application/#{n}" }

    after(:build) do |a, e|
      a.platform = e.platform
    end
  end

  factory :activity do
    transient do
      platform { create :platform }
    end

    after(:build) do |a, e|
      a.platform = e.platform
    end
  end

  factory :trace do
    transient do
      platform { create :platform }
      application { create :application, platform: platform }
      activity { create :activity, platform: platform }
    end

    start { Time.zone.now - 2.seconds }
    stop { Time.zone.now }
    name 'mnemosyne.test.trace'
    hostname 'host-0'

    after(:build) do |t, e|
      t.platform = e.platform
      t.activity = e.activity
      t.application = e.application
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

  factory :failure do
    transient do
      platform nil
      application nil
      activity nil
      stop nil

      trace do
        create(:trace, **{
          platform: platform,
          application: application,
          activity: activity,
          stop: stop
        }.compact)
      end
    end

    type 'RuntimeError'
    text 'Error Message'
    stacktrace []

    after(:build) do |f, e|
      e.trace.tap do |trace|
        f.trace = trace
        f.platform = trace.platform
        f.application = trace.application

        f.stop = trace.stop
        f.hostname = trace.hostname
      end
    end
  end
end
