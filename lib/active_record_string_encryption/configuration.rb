# frozen_string_literal: true

module ActiveRecordStringEncryption
  class Configuration
    attr_accessor :secret_key, :salt
  end
end
