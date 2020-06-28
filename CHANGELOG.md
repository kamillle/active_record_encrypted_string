## 1.1.0

- Support encrypt with other salts

```ruby
class Sample < ApplicationRecord
  # encrypt with the salt that set in config/initializers
  attribute :string_1, :encrypted_string
  # if you want to encrypt with another salt
  attribute :string_2, :encrypted_string, salt: ENV['STRING_2_ENCRYPT_SALT']
end
```

## 1.0.0

- Rename gem name to active_record_encrypted_string
- Rename type name to encrypted_string
- Return empty string if serialize or deserialize value is empty string

## 0.1.0

- First release
