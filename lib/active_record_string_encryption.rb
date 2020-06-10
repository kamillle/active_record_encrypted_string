# frozen_string_literal: true

require 'active_support/lazy_load_hooks'
require 'active_record_string_encryption/version'
require 'active_record_string_encryption/configuration'

module ActiveRecordStringEncryption
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end

ActiveSupport.on_load(:active_record) do
  require 'active_record_string_encryption/encrypt_string'

  ActiveRecord::Type.register(:encrypt_string, ActiveRecordStringEncryption::EncryptString)
end
