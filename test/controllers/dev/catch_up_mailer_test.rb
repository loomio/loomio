require 'test_helper'

class Dev::CatchUpMailerTest < ActionController::TestCase
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

  test "catch_up email renders successfully with expected structure" do
    get :setup_thread_catch_up
    assert_response :success

    # Verify the email was sent (not the 'no emails sent' error page)
    assert parsed_body.css('.error').empty?, "Expected no error message, got: #{parsed_body.css('.error').text}"

    # Verify email headers
    assert_text_in 'table', 'Subject'

    # Verify catch_up content structure
    assert_element '.everything'
    assert_element '.toc'
    assert_element '.light-discussion'
    assert_element '.activity-feed'

    # Verify discussion title link
    assert_element '.light-discussion h2 a'

    # Verify comments in the activity feed
    assert_text_in '.activity-feed', 'first comment'

    # Verify discarded comment shows removed message
    assert_text_in '.activity-feed', I18n.t('thread_item.removed')

    # Verify discussion edited with message
    assert_text_in '.activity-feed', 'this is an edit message'

    # Verify unsubscribe link
    assert_element '.unsubscribe'

    # Verify tracking pixel (mark_summary_as_read)
    assert_element 'img[width="1"][height="1"]'
  end
end
