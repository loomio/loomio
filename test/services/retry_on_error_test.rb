require 'test_helper'

class RetryOnErrorTest < ActiveSupport::TestCase
  test "retrys a limited number of times if there is an exception" do
    count = 0

    assert_raises StandardError do
      RetryOnError.with_limit(5) do
        count += 1
        raise "this is an error"
      end
    end

    assert_equal 5, count
  end

  test "runs once if no error" do
    count = 0

    RetryOnError.with_limit(5) do
      count += 1
    end

    assert_equal 1, count
  end
end
