require 'test_helper'

class ServerApiKeyTest < ActiveSupport::TestCase
  setup do
    @original = ENV.to_h.slice('SERVER_API_KEY', 'B3_API_KEY')
    ENV.delete('SERVER_API_KEY')
    ENV.delete('B3_API_KEY')
  end

  teardown do
    ENV.delete('SERVER_API_KEY')
    ENV.delete('B3_API_KEY')
    @original.each { |name, value| ENV[name] = value }
  end

  test 'boot accepts an unset key and rejects a short one under either name' do
    ServerApiKey.validate!

    ENV['B3_API_KEY'] = 'k' * 16
    assert_raises(ArgumentError) { ServerApiKey.validate! }

    ENV['SERVER_API_KEY'] = 'k' * 16
    assert_raises(ArgumentError) { ServerApiKey.validate! }

    ENV['SERVER_API_KEY'] = 'k' * 17
    ServerApiKey.validate!
    assert_equal 'k' * 17, ServerApiKey.value
  end
end
