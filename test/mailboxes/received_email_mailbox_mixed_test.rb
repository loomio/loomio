require 'test_helper'
require 'minitest/mock'

class ReceivedEmailMailboxMixedTest < ActionMailbox::TestCase
  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
    @eml_path = Rails.root.join("spec/fixtures/files/email_with_mixed_attachments.eml")
    @raw_email = File.read(@eml_path)
    @mail = Mail.read_from_string(@raw_email)
  end

  test "builds ReceivedEmail with inline and regular attachments and rewrites cid references" do
    # Save original methods and replace with stubs
    ReceivedEmail.alias_method(:_orig_is_addressed_to_loomio?, :is_addressed_to_loomio?)
    ReceivedEmail.alias_method(:_orig_is_auto_response?, :is_auto_response?)
    ReceivedEmail.define_method(:is_addressed_to_loomio?) { true }
    ReceivedEmail.define_method(:is_auto_response?) { false }

    route_called = false
    original_route = ReceivedEmailService.method(:route)
    ReceivedEmailService.define_singleton_method(:route) { |email| route_called = true }

    inbound_email = receive_inbound_email_from_source(@mail.to_s)

    assert_difference 'ReceivedEmail.count', 1 do
      ReceivedEmailMailbox.receive(inbound_email)
    end

    email = ReceivedEmail.last

    # HTML body
    assert_includes email.body_html, "rails/active_storage/blobs/redirect/"
    assert_includes email.body_html, ".png"
    assert_includes email.body_html, "<img"

    # Attachments
    assert_equal 3, email.attachments.count
    filenames = email.attachments.map { |a| a.filename.to_s }.sort
    assert_equal ["logo1.png", "logo2.png", "notes.txt"], filenames

    inline_images = email.attachments.select { |a| a.filename.to_s.start_with?("logo") }
    assert inline_images.all? { |a| a.blob.content_type == "image/png" }

    text_file = email.attachments.find { |a| a.filename.to_s == "notes.txt" }
    assert_equal "text/plain", text_file.blob.content_type
    assert_includes text_file.blob.download, "Some notes"

    # Headers and service call
    assert_equal "Multiple attachments test", email.subject
    assert_includes email.from, "alice@example.com"
    assert route_called, "Expected ReceivedEmailService.route to have been called"
  ensure
    # Restore original methods
    if ReceivedEmail.method_defined?(:_orig_is_addressed_to_loomio?)
      ReceivedEmail.define_method(:is_addressed_to_loomio?, ReceivedEmail.instance_method(:_orig_is_addressed_to_loomio?))
      ReceivedEmail.remove_method(:_orig_is_addressed_to_loomio?)
    end
    if ReceivedEmail.method_defined?(:_orig_is_auto_response?)
      ReceivedEmail.define_method(:is_auto_response?, ReceivedEmail.instance_method(:_orig_is_auto_response?))
      ReceivedEmail.remove_method(:_orig_is_auto_response?)
    end
    ReceivedEmailService.define_singleton_method(:route, original_route) if original_route
  end
end
