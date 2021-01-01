# frozen_string_literal: true

RSpec.describe ActiveRecordEncryptedString::Configuration do
  describe '#secret_key and #salt' do
    let(:secret_key) { 'secret_key' }
    let(:salt) { 'salt' }

    subject(:configuration) do
      ActiveRecordEncryptedString.configure do |c|
        c.secret_key = secret_key
        c.salt = salt
      end
      ActiveRecordEncryptedString.configuration
    end

    it do
      expect(configuration.secret_key).to eq secret_key
      expect(configuration.salt).to eq salt
    end
  end

  describe '#cipher_alg' do
    context 'do not pass cipher_alg' do
      subject do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = 'secret_key'
          c.salt = 'salt'
        end
        ActiveRecordEncryptedString.configuration.cipher_alg
      end

      it { is_expected.to eq 'aes-256-gcm' }
    end

    context 'passes cipher_alg' do
      subject do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = 'secret_key'
          c.salt = 'salt'
          c.cipher_alg = cipher_alg
        end
        ActiveRecordEncryptedString.configuration.cipher_alg
      end

      let(:cipher_alg) { 'aes-256-cbc' }

      it { is_expected.to eq cipher_alg }
    end
  end

  describe '#defined_decryption_error_handler?' do
    context 'do not pass decryption_error_handler' do
      subject do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = 'secret_key'
          c.salt = 'salt'
        end
        ActiveRecordEncryptedString.configuration.defined_decryption_error_handler?
      end

      it { is_expected.to eq false }
    end

    context 'passes decryption_error_handler that does not have call interface' do
      subject(:configuration) do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = 'secret_key'
          c.salt = 'salt'
          c.decryption_error_handler = handler
        end
        ActiveRecordEncryptedString.configuration.defined_decryption_error_handler?
      end
      let(:handler) do
        puts 'this is handler'
      end

      it { is_expected.to eq false }
    end

    context 'passes decryption_error_handler that has call interface' do
      subject(:configuration) do
        ActiveRecordEncryptedString.configure do |c|
          c.secret_key = 'secret_key'
          c.salt = 'salt'
          c.decryption_error_handler = handler
        end
        ActiveRecordEncryptedString.configuration.defined_decryption_error_handler?
      end
      let(:handler) do
        ->(exception, value) {
          value
        }
      end

      it { is_expected.to eq true }
    end
  end
end
