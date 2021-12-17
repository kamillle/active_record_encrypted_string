## Unreleased

- [#x](https://github.com/kamillle/active_record_encrypted_string/pull/x) Please describe

## 1.4.0

- [#24](https://github.com/kamillle/active_record_encrypted_string/pull/24) Support Rails7

## 1.3.1

- [#23](https://github.com/kamillle/active_record_encrypted_string/pull/23) Testing by Ruby3
- [#20](https://github.com/kamillle/active_record_encrypted_string/pull/20) Run tests by GitHub Actions

## 1.3.0

- [#13](https://github.com/kamillle/active_record_encrypted_string/pull/16) Override changed_in_place? for handling changes

   Thanks @ericproulx :heart:

## 1.2.1

- [#13](https://github.com/kamillle/active_record_encrypted_string/pull/13) Replace to rspec-parameterized-context
- [#12](https://github.com/kamillle/active_record_encrypted_string/pull/12) Introduce pry-byebug
- [#11](https://github.com/kamillle/active_record_encrypted_string/pull/11) Ignore Gemfile.lock

## 1.2.0

- [#7](https://github.com/kamillle/active_record_encrypted_string/pull/7) Support Rails v6.1.0rc1

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
