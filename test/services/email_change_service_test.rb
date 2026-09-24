require 'test_helper'

class EmailChangeServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @old_email = @user.email
    @new_email = 'new-address@example.com'
    ActionMailer::Base.deliveries.clear
  end

  test 'a request keeps the active email and sends the link only to the new address' do
    perform_enqueued_jobs do
      EmailChangeService.request(user: @user, actor: @user, email: @new_email)
    end

    assert_equal @old_email, @user.reload.email
    assert_equal @new_email, @user.email_change_pending
    assert_equal [@new_email, @old_email].sort, ActionMailer::Base.deliveries.flat_map(&:to).sort
    assert EmailChangeService.valid_confirmation?(user: @user, token: confirmation_token)
    refute_includes ActionMailer::Base.deliveries.find { |mail| mail.to == [@old_email] }.html_part.body.decoded, 'token='
  end

  test 'confirmation changes the email once and preserves existing sessions and credentials' do
    login_token = @user.login_tokens.create!
    session = @user.sessions.create!(user_agent: 'existing browser')
    old_api_key = @user.api_key
    old_email_api_key = @user.email_api_key
    request_change
    token = confirmation_token

    perform_enqueued_jobs do
      EmailChangeService.confirm(user: @user, token: token)
    end

    assert_equal @new_email, @user.reload.email
    assert @user.email_verified?
    assert_nil @user.email_change_pending
    assert_equal old_api_key, @user.api_key
    assert_equal old_email_api_key, @user.email_api_key
    assert LoginToken.exists?(login_token.id)
    assert Session.exists?(session.id)
    refute EmailChangeService.valid_confirmation?(user: @user, token: token)
    assert_raises(EmailChangeService::InvalidConfirmation) do
      EmailChangeService.confirm(user: @user, token: token)
    end
    assert_includes ActionMailer::Base.deliveries.flat_map(&:to), @old_email
  end

  test 'a newer request invalidates the older confirmation link' do
    request_change
    old_token = confirmation_token

    perform_enqueued_jobs do
      EmailChangeService.request(user: @user, actor: @user, email: 'third-address@example.com')
    end

    refute EmailChangeService.valid_confirmation?(user: @user, token: old_token)
    assert_raises(EmailChangeService::InvalidConfirmation) do
      EmailChangeService.confirm(user: @user, token: old_token)
    end
    assert_equal @old_email, @user.reload.email
  end

  test 'confirmation expires after one day' do
    request_change
    token = confirmation_token

    travel 25.hours do
      refute EmailChangeService.valid_confirmation?(user: @user, token: token)
      assert_raises(EmailChangeService::InvalidConfirmation) do
        EmailChangeService.confirm(user: @user, token: token)
      end
    end
    assert_equal @old_email, @user.reload.email
  end

  test 'a confirmation link is bound to its account' do
    request_change

    assert_raises(EmailChangeService::InvalidConfirmation) do
      EmailChangeService.confirm(user: users(:alien), token: confirmation_token)
    end
    assert_equal @old_email, @user.reload.email
  end

  test 'a request for an address already used by another account is rejected' do
    assert_raises(ActiveRecord::RecordInvalid) do
      EmailChangeService.request(user: @user, actor: @user, email: users(:alien).email)
    end
    assert_equal @old_email, @user.reload.email
    assert_nil @user.email_change_pending
  end

  private

  def request_change
    perform_enqueued_jobs do
      EmailChangeService.request(user: @user, actor: @user, email: @new_email)
    end
  end

  def confirmation_token
    mail = ActionMailer::Base.deliveries.reverse.find { |delivery| delivery.to == [@new_email] }
    link = Nokogiri::HTML(mail.html_part.body.decoded).at_css('a.email-button')['href']
    Rack::Utils.parse_query(URI.parse(link).query).fetch('token')
  end
end
