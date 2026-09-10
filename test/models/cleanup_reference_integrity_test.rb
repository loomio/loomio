require "test_helper"
require_relative "../support/access_volume_matrix"

class CleanupReferenceIntegrityTest < ActiveSupport::TestCase
  include AccessVolumeMatrix

  test "failed raw poll deletion preserves choices outcomes and access on group and direct topics" do
    before = access_volume_matrix
    %i[discussion_topic direct_topic].each do |topic_name|
      topic = topics(topic_name)
      actor = topic_name == :direct_topic ? users(:guest_admin_normal) : users(:admin)
      poll = PollService.create(params: {
        topic_id: topic.id, title: "Retained vote", poll_type: "proposal",
        poll_option_names: %w[Agree Disagree], closing_at: 1.day.from_now
      }, actor: actor)
      stance = poll.stances.find_by!(participant: actor)
      stance.stance_choices.create!(poll_option: poll.poll_options.first, score: 1)
      PollService.close(poll: poll, actor: actor)
      outcome = Outcome.create!(poll: poll, author: actor, statement: "Keep this decision")
      records = [ poll, stance, stance.stance_choices.first, outcome ].to_h { |record| [ record, record.reload.attributes ] }

      assert_raises(ActiveRecord::InvalidForeignKey) do
        Poll.transaction(requires_new: true) { Poll.where(id: poll.id).delete_all }
      end
      records.each { |record, attributes| assert_equal attributes, record.reload.attributes }

      # Normal destruction must still execute the dependency callbacks in order.
      poll.destroy!
      records.each_key { |record| assert_not record.class.exists?(record.id) }
      assert Topic.exists?(topic.id)
    end
    assert_access_volume_matrix_unchanged(before)
  end

  test "required group metadata cannot evade the foreign key with a null reference" do
    [ MembershipRequest, Tag ].each do |model|
      record = if model == Tag
        tags(:cleanup_tag)
      else
        MembershipRequest.create!(group: groups(:group), requestor: users(:alien))
      end
      attributes = record.attributes
      assert_raises(ActiveRecord::NotNullViolation) do
        model.transaction(requires_new: true) { record.update_column(:group_id, nil) }
      end
      assert_equal attributes, record.reload.attributes
    end
  end
end
