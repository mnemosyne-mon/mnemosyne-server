# frozen_string_literal: true

require "rails_helper"
require "server/builder"

RSpec.describe Server::Builder do
  subject(:call) { builder.call(payload) }

  let(:payload) { {} }
  let(:builder) { described_class.new }

  context "with payload (I)" do
    let(:payload) do
      {
        uuid: "cd25562f-42e6-48e6-9f3b-08632da38921",
        origin: "38653828-54e2-4c5a-ab4d-45fa4e24ef79",
        transaction: "4c6d1d78-3eec-4ac8-9720-80baff80e1f8",
        application: "Mnemosyne/Application",
        platform: "my-platform",
        hostname: "services-1",
        name: "example.trace.mnemosyne",
        start: 0,
        stop: 1_000_000_000,
        span: [{
          uuid: "d9a6f0f0-eff4-4f43-af75-9d15ba2de93c",
          name: "example.span.mnemosyne",
          start: 100_000_000,
          stop: 200_000_000,
        }],
        errors: [{
          type: "RuntimeError",
          text: "error message",
          stacktrace: [{
            file: "(pry)",
            line: "2",
            call: "m",
            raw: "(pry):2:in `m'",
          }, {
            file: "/home/jan/.rvm/gems/ruby-2.4.2/gems/pry-0.10.4/lib/pry/pry_instance.rb",
            line: "355",
            call: "eval",
            raw: "/home/jan/.rvm/gems/ruby-2.4.2/gems/pry-0.10.4/lib/pry/pry_instance.rb:355:in `eval'",
          },],
        }],
      }
    end

    let(:trace) { Trace.find payload.fetch(:uuid) }

    it "creates platform" do
      expect { call }.to change(Platform, :count).from(0).to(1)
    end

    it "creates application" do
      expect { call }.to change(Application, :count).from(0).to(1)
    end

    it "creates trace" do
      expect { call }.to change(Trace, :count).from(0).to(1)
    end

    it "creates two spans" do
      expect { call }.to change(Span, :count).from(0).to(2)
    end

    it "creates failure" do
      expect { call }.to change(Failure, :count).from(0).to(1)
    end

    describe "platform" do
      subject(:platform) { trace.platform }

      before { call }

      example "name equals payload value" do
        expect(platform.name).to eq "my-platform"
      end
    end

    describe "activity" do
      subject(:activity_id) { trace.activity_id }

      before { call }

      example "UUID equals payload value" do
        expect(activity_id).to eq "4c6d1d78-3eec-4ac8-9720-80baff80e1f8"
      end
    end

    describe "application" do
      subject(:application) { trace.application }

      before { call }

      example "original name equals payload value" do
        expect(application.name).to eq "Mnemosyne/Application"
      end

      example "correct platform is associated" do
        expect(application.platform.name).to eq "my-platform"
      end
    end

    describe "trace" do
      before { call }

      example "UUID equals payload value" do
        expect(trace.id).to eq "cd25562f-42e6-48e6-9f3b-08632da38921"
      end

      example "origin equals payload value" do
        expect(trace.origin_id).to eq "38653828-54e2-4c5a-ab4d-45fa4e24ef79"
      end

      example "name equals payload value" do
        expect(trace.name).to eq "example.trace.mnemosyne"
      end

      example "start time equals payload value" do
        expect(trace.start).to eq Time.at(0).utc
      end

      example "stop time equals payload value" do
        expect(trace.stop).to eq Time.at(1).utc
      end

      example "hostname equals payload value" do
        expect(trace.hostname).to eq "services-1"
      end

      example "correct activity is associated" do
        expect(trace.activity_id).to eq "4c6d1d78-3eec-4ac8-9720-80baff80e1f8"
      end
    end

    describe "spans" do
      before { call }

      example "first matches trace" do
        trace.spans[0].tap do |span|
          expect(span.id).to eq "cd25562f-42e6-48e6-9f3b-08632da38921"
          expect(span.name).to eq "example.trace.mnemosyne"
          expect(span.start).to eq Time.at(0).utc
          expect(span.stop).to eq Time.at(1).utc
        end
      end

      example "second matches include span record" do
        trace.spans[1].tap do |span|
          expect(span.id).to eq "d9a6f0f0-eff4-4f43-af75-9d15ba2de93c"
          expect(span.name).to eq "example.span.mnemosyne"
          expect(span.start).to eq Time.at(Rational(1, 10)).utc
          expect(span.stop).to eq Time.at(Rational(2, 10)).utc
          expect(span.trace_id).to eq "cd25562f-42e6-48e6-9f3b-08632da38921"
        end
      end
    end

    describe "failures" do
      subject(:failure) { trace.failures.first }

      before { call }

      example "type equals payload value" do
        expect(failure.type).to eq "RuntimeError"
      end

      example "text equals payload value" do
        expect(failure.text).to eq "error message"
      end

      example "hostname equals payload value" do
        expect(failure.hostname).to eq "services-1"
      end

      example "correct trace is associated" do
        expect(failure.trace_id).to eq "cd25562f-42e6-48e6-9f3b-08632da38921"
      end

      example "correct application is associated" do
        expect(failure.application_id).to eq trace.application.id
      end

      example "correct platform is associated" do
        expect(failure.platform_id).to eq trace.platform.id
      end

      example "stacktrace equals payload value" do
        expect(failure.stacktrace).to eq [{
          "file" => "(pry)",
          "line" => 2,
          "call" => "m",
        }, {
          "file" => "/home/jan/.rvm/gems/ruby-2.4.2/gems/pry-0.10.4/lib/pry/pry_instance.rb",
          "line" => 355,
          "call" => "eval",
        },]
      end
    end
  end
end
