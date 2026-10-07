require "test_helper"
require Rails.root.join("db/migrate/support/stance_user_reference_integrity_cleanup")

class StanceUserReferenceIntegrityCleanupTest < ActiveSupport::TestCase
  test "deletes stances of missing users and clears missing actors without recounting results" do
    poll = PollService.create(params: {
      title: "Orphan stances", poll_type: "proposal", group_id: groups(:group).id,
      poll_option_names: %w[agree disagree], closing_at: 3.days.from_now
    }, actor: users(:admin))
    voter = User.create!(name: "Kept voter", email: "kept-#{SecureRandom.hex(4)}@example.com", email_verified: true)
    missing_user_id = User.maximum(:id) + 1
    now = Time.current
    stance_counts_recorded = [7.0, 3.0]
    poll.update_columns(stance_counts: stance_counts_recorded)

    attributes = {
      poll_id: poll.id, latest: true, created_at: now, updated_at: now,
      inviter_id: nil, revoker_id: nil, redactor_id: nil
    }
    # Fire the poll's deferred constraint checks so its tables can be altered.
    ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL IMMEDIATE")
    orphan_id = kept_id = nil
    ActiveRecord::Base.connection.disable_referential_integrity do
      orphan_id, kept_id = Stance.insert_all!([
        attributes.merge(participant_id: missing_user_id, token: SecureRandom.hex(10)),
        attributes.merge(
          participant_id: voter.id, token: SecureRandom.hex(10),
          inviter_id: missing_user_id, revoker_id: missing_user_id, redactor_id: missing_user_id
        )
      ]).rows.flatten
    end

    StanceUserReferenceIntegrityCleanup.run!(ActiveRecord::Base.connection)

    assert_not Stance.exists?(orphan_id)
    kept_stance = Stance.find(kept_id)
    assert_nil kept_stance.inviter_id
    assert_nil kept_stance.revoker_id
    assert_nil kept_stance.redactor_id
    assert_equal voter.id, kept_stance.participant_id
    assert_equal stance_counts_recorded, poll.reload.stance_counts
  end

  test "deleting a user removes their stances and clears their actor references" do
    poll = PollService.create(params: {
      title: "Deleted voter", poll_type: "proposal", group_id: groups(:group).id,
      poll_option_names: %w[agree disagree], closing_at: 3.days.from_now
    }, actor: users(:admin))
    voter = User.create!(name: "Deleted voter", email: "deleted-#{SecureRandom.hex(4)}@example.com", email_verified: true)
    voter_stance = poll.stances.create!(participant: voter, latest: true)
    admin_stance = poll.stances.find_by!(participant: users(:admin))
    admin_stance.update_columns(inviter_id: voter.id)

    User.where(id: voter.id).delete_all

    assert_not Stance.exists?(voter_stance.id)
    assert_nil admin_stance.reload.inviter_id
  end
end
