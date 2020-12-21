# frozen_string_literal: true

module ActiveRecordEncryptedString
  class Type < ActiveRecord::Type::String
    class << self
      def key_len
        ActiveSupport::MessageEncryptor.key_len(ActiveRecordEncryptedString.configuration.cipher_alg)
      end
    end

    def initialize(**options)
      @salt = options[:salt]
    end

    # ActiveRecord calls `serialize` to convert Ruby objects to a format that can be understood by database
    def serialize(value)
      # expects same behavior as ActiveRecord::Type::String other than encryption
      # https://github.com/rails/rails/blob/5-0-stable/activemodel/lib/active_model/type/immutable_string.rb
      v = super(value)
      v.present? ? encryptor.encrypt_and_sign(v) : v
    end

    # ActiveRecord calls `deserialize` to convert values stored database to Ruby objects
    def deserialize(value)
      # expects same behavior as ActiveRecord::Type::String other than decryption
      # https://github.com/rails/rails/blob/5-0-stable/activemodel/lib/active_model/type/value.rb#L21-L23
      v = super(value)
      v.present? ? encryptor.decrypt_and_verify(v) : v
    end

    def changed_in_place?(raw_old_value, new_value)
      deserialize(raw_old_value) != new_value if new_value.is_a?(::String)
    end

    private

    def encryptor
      # TODO: rotate
      ActiveSupport::MessageEncryptor.new(secret, cipher: ActiveRecordEncryptedString.configuration.cipher_alg)
    end

    def secret
      ActiveSupport::KeyGenerator.new(secret_key).generate_key(salt, self.class.key_len)
    end

    def secret_key
      ActiveRecordEncryptedString.configuration.secret_key
    end

    def salt
      @salt || ActiveRecordEncryptedString.configuration.salt
    end
  end
end
