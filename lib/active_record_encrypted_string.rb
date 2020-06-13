# frozen_string_literal: true

require 'active_support/lazy_load_hooks'
require 'active_record_encrypted_string/version'
require 'active_record_encrypted_string/configuration'

module ActiveRecordEncryptedString
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
  require 'active_record_encrypted_string/encrypted_string'

  ActiveRecord::Type.register(:encrypted_string, ActiveRecordEncryptedString::EncryptedString)
end
