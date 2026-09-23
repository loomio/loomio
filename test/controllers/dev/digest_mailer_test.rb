require 'test_helper'

class Dev::DigestMailerTest < ActionController::TestCase
  tests Dev::NightwatchController

  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
  end

  private

  def parsed_body
    Nokogiri::HTML(response.body)
  end

  def assert_text_in(selector, val)
    text = parsed_body.css(selector).text
    assert_includes text, val, "Expected text in '#{selector}' to include '#{val}', got: #{text.truncate(200)}"
  end

  def assert_element(selector)
    assert parsed_body.css(selector).any?, "Expected element '#{selector}' to exist"
  end

  public

  test "digest email renders successfully with expected structure" do
    get :setup_thread_digest
    assert_response :success

    # Verify the email was sent (not the 'no emails sent' error page)
    assert parsed_body.css('.error').empty?, "Expected no error message, got: #{parsed_body.css('.error').text}"

    # Verify email headers
    assert_text_in 'table', 'Subject'

    # Verify catch-up content structure
    assert_element 'main'
    assert_element '.email-thread'
    assert_element '.email-thread-activity'

    # Verify discussion title link
    assert_element '.email-thread h4 a'

    # Verify comments in the activity feed
    assert_text_in '.email-thread-activity', 'first comment'

    # Verify discarded comment shows removed message
    assert_text_in '.email-thread-activity', I18n.t('thread_item.removed')

    # Verify discussion edited with message
    assert_text_in '.email-thread-activity', 'this is an edit message'

    # Verify notification-style branding and unsubscribe footer
    assert parsed_body.css('.email-header-logo').empty?
    assert_element '.email-footer-logo'
    assert_element 'a[href*="email_preferences"]'

    # Reading the catch-up is acknowledged explicitly rather than by image loading.
    assert_text_in 'a[href*="mark_digest_as_read"]', I18n.t('email.catch_up.mark_catch_up_as_read')
    assert parsed_body.css('img[width="1"][height="1"]').empty?
  end

  test "Oatmilk digest email leads with two notifications and one group's unread thread activity" do
    get :setup_manual_oatmilk_digest_email
    assert_response :success

    assert parsed_body.css('.error').empty?, "Expected no error message, got: #{parsed_body.css('.error').text}"
    assert_text_in 'table', '2 people mentioned you'
    assert_text_in 'main > h1', "Your #{AppConfig.theme[:site_name]} catch-up"
    assert_text_in 'main', 'Oatmilk Cooperative'
    assert_text_in 'main', 'Weekly production schedule'
    assert_text_in 'main', 'Jamie, could you confirm the cafe collection schedule'
    assert_text_in 'main', 'I added the latest return-rate figures'

    notification_avatar_names = parsed_body.css('.email-notification .email-avatar').map { |image| image['alt'] }
    assert_equal ['Alex Morgan', 'Samira Patel'], notification_avatar_names
    assert_operator parsed_body.text.index('Notifications'), :<, parsed_body.text.index('Unread threads')
    assert_text_in 'a[href*="mark_digest_as_read"]', I18n.t('email.catch_up.mark_catch_up_as_read')
  end

  test "digest email includes standalone polls" do
    get :setup_thread_digest_with_standalone_poll
    assert_response :success

    assert parsed_body.css('.error').empty?, "Expected no error message, got: #{parsed_body.css('.error').text}"

    assert_element 'main'

    # Discussion thread is present
    assert_text_in 'main', 'What star sign are you?'
    assert_text_in '.email-thread-activity', 'first comment'

    # Standalone poll is present
    assert_text_in 'main', 'Standalone proposal'
  end
end
