require 'test_helper'

class SpamRuleHitConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test 'concurrent writers preserve every increment in a single minute bucket' do
    rule = SpamRule.create!(kind: 'ip', pattern: '198.51.100.0/24')
    at = Time.current.beginning_of_minute
    ready, start = Queue.new, Queue.new
    threads = 4.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          start.pop
          20.times { SpamRuleHit.record!(rule_id: rule.id, action: 'access', at: at) }
        end
      end
    end
    4.times { ready.pop }
    4.times { start << true }
    threads.each { |thread| assert thread.join(10), 'counter writer did not finish' }
    assert_equal 80, rule.hits.sole.count
  ensure
    threads&.each { |thread| thread.kill if thread.alive? }
  end
end
