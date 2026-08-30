require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "mailuser#{hex}", email: "mailuser#{hex}@example.com", username: "mailuser#{hex}", email_verified: true)
    @inviter = User.create!(name: "mailinviter#{hex}", email: "mailinviter#{hex}@example.com", username: "mailinviter#{hex}", email_verified: true)
    @group = Group.new(name: "Mailgroup #{hex}", group_privacy: 'secret', handle: "mailgroup#{hex}")
    @group.creator = @inviter
    @group.save!
  end

  test "group_export_ready sends email with download link" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("csv,data"),
      filename: "export.csv",
      content_type: "text/csv"
    )

    mail = UserMailer.group_export_ready(@user.id, @group.full_name, blob.signed_id)

    assert_equal [@user.email], mail.to
    assert_equal I18n.t(
      "user_mailer.group_export_ready.subject",
      group_name: @group.full_name,
      locale: @user.locale
    ), mail.subject
    assert_match "/rails/active_storage/blobs/", mail.body.encoded
  end
end
