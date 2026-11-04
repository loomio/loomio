require "test_helper"

class TopicReaderRedemptionTest < ActiveSupport::TestCase
  # Exercise the actual unique constraint and rollback used by request-time
  # redemption. A fixture transaction would remain aborted after the collision.
  self.use_transactional_tests = false

  test "redeeming a second invitation preserves the existing guest reader and accepts its invitation" do
    actor = users(:guest_normal)
    pending_user = User.create!(name: "Pending invitee", email: "pending-redemption@example.test", email_verified: false)

    freeze_time do
      %i[discussion_topic direct_topic].each do |topic_name|
        topic = topics(topic_name)
        existing = TopicReader.find_by!(topic: topic, user: actor)
        existing.update!(volume_email: :quiet, volume_push: :loud, read_ranges_string: "1-3")
        invitation = TopicReader.create!(topic: topic, user: pending_user, inviter: users(:admin), guest: true)
        assert TopicReader.redeemable_by(actor).exists?(invitation.id)

        TopicReaderService.redeem(topic_reader: invitation, actor: actor)

        assert_not TopicReader.exists?(invitation.id)
        assert_equal [existing.id], TopicReader.where(topic: topic, user: actor).pluck(:id)
        existing.reload
        assert_equal Time.current, existing.accepted_at
        assert_equal users(:admin).id, existing.inviter_id
        assert existing.guest?
        assert existing.email_quiet?
        assert existing.push_loud?
        assert_equal "1-3", existing.read_ranges_string
      end
    end
  end
end
