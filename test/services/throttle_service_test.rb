require 'test_helper'

class ThrottleServiceTest < ActiveSupport::TestCase
  setup do
    CACHE_REDIS_POOL.with { |client| client.flushall }
  end

  test "limits the number of times i can do something" do
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)
    assert_equal false, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 1)
  end

  test "limits the number of times i can do something, with inc" do
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    assert_equal false, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    assert_equal true, ThrottleService.can?(key: 'jump', id: 2, max: 5, per: 'hour', inc: 2)
    assert_equal true, ThrottleService.can?(key: 'jump', id: 2, max: 5, per: 'hour', inc: 2)
    assert_equal false, ThrottleService.can?(key: 'jump', id: 2, max: 5, per: 'hour', inc: 2)
  end

  test "correctly resets a throttle" do
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    assert_equal false, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    ThrottleService.reset!('hour')
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
  end

  test "does not reset all throttles" do
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    assert_equal true, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    assert_equal false, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
    ThrottleService.reset!('day')
    assert_equal false, ThrottleService.can?(key: 'jump', max: 5, per: 'hour', inc: 2)
  end

  test "raises exception for limit!" do
    assert_equal true, ThrottleService.limit!(key: 'jump', max: 1, per: 'hour', inc: 1)
    assert_raises ThrottleService::LimitReached do
      ThrottleService.limit!(key: 'jump', max: 1, per: 'hour', inc: 1)
    end
  end
end
