require 'test_helper'

class SpamRuleDeliveryTest < ActionMailer::TestCase
  test 'blocked domains suppress new delivery without matching lookalikes' do
    rule = SpamRule.create!(kind: 'email_domain', pattern: 'blocked.example')
    assert_no_emails { UserMailer.redacted('user@blocked.example', 'en').deliver_now }
    assert_emails 1 do
      UserMailer.redacted('user@notblocked.example', 'en').deliver_now
    end
    assert_equal 1, rule.hits.where(action: 'email').sum(:count)
  end

  test 'mail prepared before a ban is suppressed at the delivery boundary' do
    message = UserMailer.redacted('user@blocked.example', 'en').message
    rule = SpamRule.create!(kind: 'email_domain', pattern: 'blocked.example')
    assert_no_emails { message.deliver }
    assert_equal 1, rule.hits.where(action: 'email').sum(:count)
  end

  test 'mixed To CC and BCC recipients keep only allowed addresses' do
    message = Mail.new do
      to 'allowed@example.com'
      cc 'blocked@blocked.example'
      bcc 'hidden@blocked.example'
      from 'sender@example.com'
      subject 'Mixed recipients'
      body 'A message'
    end
    rule = SpamRule.create!(kind: 'email_domain', pattern: 'blocked.example')
    SpamMailInterceptor.delivering_email(message)
    assert_equal [ 'allowed@example.com' ], message.destinations
    assert_equal 2, rule.hits.where(action: 'email').sum(:count)
    assert message.perform_deliveries
  end
end
