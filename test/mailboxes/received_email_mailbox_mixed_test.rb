require 'test_helper'

class ReceivedEmailMailboxMixedTest < ActionMailbox::TestCase
  test 'publishes mixed attachments and inline images from the original MIME source' do
    user = users(:admin)
    group = groups(:group)
    mail = Mail.read_from_string(File.binread(Rails.root.join('spec/fixtures/files/email_with_mixed_attachments.eml')))
    mail.from = user.email
    mail.to = "#{group.handle}@#{ENV.fetch('REPLY_HOSTNAME')}"
    assert_difference 'Discussion.count', 1 do
      receive_inbound_email_from_source(mail.encoded)
    end
    discussion = Discussion.order(:id).last
    assert_equal user, discussion.author
    assert_includes discussion.body, 'rails/active_storage/blobs/redirect/'
    refute_includes discussion.body, 'cid:'
    assert_equal %w[logo1.png logo2.png notes.txt], discussion.files.map { |file| file.filename.to_s }.sort
    assert_includes discussion.files.find { |file| file.filename.to_s == 'notes.txt' }.download, 'Some notes'
    assert_empty PendingEmail.all
  end
end
