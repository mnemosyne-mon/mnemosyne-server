# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically
# be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = false
  end

  task(:default).clear.enhance %i(rubocop spec)
rescue LoadError # rubocop:disable HandleExceptions
  # noop
end

namespace :assets do
  task(:clobber) { Rake::Task['webpacker:clobber'].invoke }
  task(:precompile) { Rake::Task['webpacker:compile'].invoke }
end
