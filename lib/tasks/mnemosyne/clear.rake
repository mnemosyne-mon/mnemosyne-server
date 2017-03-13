# frozen_string_literal: true
namespace :mnemosyne do
  desc 'Clear all applications, traces and spans'
  task clear: :environment do
    ActiveRecord::Base.transaction do
      Application.delete_all
      Trace.delete_all
      Span.delete_all
    end
  end
end
