# frozen_string_literal: true

RSpec.describe ActiveRecordEncryptedString do
  describe 'version' do
    it 'has a version number' do
      expect(ActiveRecordEncryptedString::VERSION).not_to be nil
    end
  end
end
