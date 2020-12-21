# frozen_string_literal: true

require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

# uncomment next line to visualize sql statements
# ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)
