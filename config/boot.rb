ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Ruby's `logger` is a default gem, not auto-required. ActiveSupport (6.1.x)
# assumes `::Logger` already exists by the time it loads and doesn't require
# it itself, which gem version churn in the dependency tree can expose as
# "uninitialized constant ActiveSupport::LoggerThreadSafeLevel::Logger".
# Requiring it explicitly here, before anything else, avoids that regardless
# of load order.
require 'logger'

require 'bundler/setup' # Set up gems listed in the Gemfile.
