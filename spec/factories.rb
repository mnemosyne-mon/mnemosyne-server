# frozen_string_literal: true

FactoryGirl.define do
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
    start { Time.zone.now }
    stop { Time.zone.now }
    name 'mnemosyne.test.trace'

    association :application
    association :activity
  end

  factory :span do
    start { Time.zone.now }
    stop { Time.zone.now }
    name 'mnemosyne.test.span'

    association :trace
  end
end
