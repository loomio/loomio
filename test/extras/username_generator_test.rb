require 'test_helper'

class UsernameGeneratorTest < ActiveSupport::TestCase
  test "provides a username based on name" do
    user = User.new(name: "howdy ho")
    assert_equal "howdyho", UsernameGenerator.new(user).generate
  end

  test "lowercases a username" do
    user = User.new(name: "HOWDY HO")
    assert_equal "howdyho", UsernameGenerator.new(user).generate
  end

  test "converts non-ASCII characters" do
    user = User.new(name: "hædy ho")
    assert_equal "haedyho", UsernameGenerator.new(user).generate
  end

  test "applies a number-modified username if the current one is taken" do
    User.create!(name: "howdy ho", username: "howdyho", email: "howdyho_#{SecureRandom.hex(4)}@example.com")
    user = User.new(name: "howdy ho")
    result = UsernameGenerator.new(user).generate
    assert_match(/\Ahowdyho\d+\z/, result)
  end
end
