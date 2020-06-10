# frozen_string_literal: true

RSpec.configure do |config|
  if ENV['CI']
    config.before(focus: true) { raise "Don't use focus tag in CI" }
  else
    # Run specific tests with f tag. (e.g. fdescribe, fcontext, fit)
    config.filter_run_when_matching :focus
  end
end
