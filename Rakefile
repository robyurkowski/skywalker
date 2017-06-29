require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)
  RSpec::Core::RakeTask.new(:example_spec) do |t|
    t.ruby_opts = '-C examples'
  end

  desc "Runs both primary and example specs."
  task default: [:spec, :example_spec]
rescue
end
