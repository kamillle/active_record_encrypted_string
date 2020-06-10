# frozen_string_literal: true

require 'active_support/lazy_load_hooks'
require 'active_record_string_encryption/version'

module ActiveRecordStringEncryption
  class Error < StandardError; end
  # Your code goes here...
end

ActiveSupport.on_load(:active_record) do
  require 'active_record_string_encryption/encrypt_string'

  ActiveRecord::Type.register(:encrypt_string, ActiveRecordStringEncryption::EncryptString)
end
