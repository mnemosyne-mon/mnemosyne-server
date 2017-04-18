# frozen_string_literal: true

FactoryGirl.define do
  factory :application do
    sequence(:name) {|n| "Spec Application ##{n}" }
  end

  factory :activity do
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
