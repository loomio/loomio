require 'test_helper'

class Clients::BaseTest < ActiveSupport::TestCase
  test "default failure log does not include access token" do
    previous_logger = Rails.logger
    log_output = StringIO.new
    Rails.logger = ActiveSupport::Logger.new(log_output)

    client = Clients::Base.new(token: 'secret-access-token')
    response = 'unauthorized'

    assert_equal response, client.send(:default_failure).call(response)
    refute_includes log_output.string, 'secret-access-token'
  ensure
    Rails.logger = previous_logger
  end
end
