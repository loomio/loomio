require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "reserved demo addresses are rejected with or without a display name" do
    [
      "alex@oatmilk.example",
      '"Alex Morgan" <alex@oatmilk.example>',
      "alex@EXAMPLE",
      "alex@demo.oatmilk.EXAMPLE"
    ].each do |address|
      assert_no_emails do
        UserMailer.redacted(address, "en").deliver_now
      end
    end
  end

  test "normal domains containing example still receive mail" do
    [ "alex@example.com", "alex@oatmilk.example.org", "alex@notexample.org" ].each do |address|
      assert_emails 1 do
        UserMailer.redacted(address, "en").deliver_now
      end
      assert_equal [ address ], ActionMailer::Base.deliveries.last.to
    end
  end
end
