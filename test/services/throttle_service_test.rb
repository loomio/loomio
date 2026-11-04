require 'test_helper'

class ThrottleServiceTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
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

  test "supports per-minute throttles" do
    assert ThrottleService.can?(key: 'jump', max: 1, per: 'minute')
    assert_not ThrottleService.can?(key: 'jump', max: 1, per: 'minute')
  end

  test "normalizes symbol periods for counting and resetting throttles" do
    assert ThrottleService.can?(key: 'jump', max: 1, per: :hour)
    assert_not ThrottleService.can?(key: 'jump', max: 1, per: 'hour')

    ['hour', :hour].each do |period|
      ThrottleService.reset!(period)

      assert ThrottleService.can?(key: 'jump', max: 1, per: period)
      assert_not ThrottleService.can?(key: 'jump', max: 1, per: 'hour')
    end
  end

  test "rejects unsupported periods when counting or resetting throttles" do
    assert_raises(RuntimeError) { ThrottleService.can?(key: 'jump', per: 'week') }
    assert_raises(RuntimeError) { ThrottleService.reset!('week') }
  end

  test "rejects unsupported periods when building cache keys" do
    assert_raises(RuntimeError) { ThrottleService.cache_key(key: 'jump', id: 1, per: 'week') }
  end

  test "normalizes throttle keys for environment overrides" do
    ENV['THROTTLE_MAX_JUMP_HIGH'] = '1'

    assert ThrottleService.can?(key: 'JumpHigh')
    assert_not ThrottleService.can?(key: 'JumpHigh')
  ensure
    ENV.delete('THROTTLE_MAX_JUMP_HIGH')
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
