require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "production rejects reserved demo addresses with or without a display name" do
    [
      "alex@oatmilk.example",
      '"Alex Morgan" <alex@oatmilk.example>',
      "alex@EXAMPLE",
      "alex@demo.oatmilk.EXAMPLE"
    ].each do |address|
      Rails.env.stub(:production?, true) do
        assert_no_emails do
          UserMailer.redacted(address, "en").deliver_now
        end
      end
    end
  end

  test "normal domains containing example still receive mail" do
    [ "alex@example.com", "alex@oatmilk.example.org", "alex@notexample.org" ].each do |address|
      Rails.env.stub(:production?, true) do
        assert_emails 1 do
          UserMailer.redacted(address, "en").deliver_now
        end
      end
      assert_equal [ address ], ActionMailer::Base.deliveries.last.to
    end
  end

  test "non-production previews render mail for reserved demo addresses" do
    assert_emails 1 do
      UserMailer.redacted("alex@oatmilk.example", "en").deliver_now
    end
    assert_equal [ "alex@oatmilk.example" ], ActionMailer::Base.deliveries.last.to
  end
end
