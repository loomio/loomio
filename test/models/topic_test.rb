require "test_helper"

class TopicTest < ActiveSupport::TestCase
  test "tag refresh waits for a successful commit and is discarded on rollback" do
    topic = topics(:discussion_topic)
    assert_no_enqueued_jobs(only: UpdateGroupAndOrgTagsWorker) do
      Topic.transaction(requires_new: true) do
        topic.update!(tags: [ "Rolled back" ])
        raise ActiveRecord::Rollback
      end
    end

    assert_enqueued_with(job: UpdateGroupAndOrgTagsWorker, args: [ topic.group_id ]) do
      topic.reload.update!(tags: [ "Committed" ])
    end
  end

  test "members match the fixture access matrix exactly" do
    matrix = {
      current_members: %i[
        admin user member member_quiet member_normal member_loud
        reader_quiet reader_normal reader_loud member_guest_loud
      ],
      current_guests: %i[
        guest_quiet guest_normal guest_admin_normal guest_loud member_guest_loud former_member_guest
      ],
      other_group_members: %i[alien alien_quiet alien_loud],
      non_guest_readers: %i[non_guest_loud],
      former_members: %i[former_member_loud],
      former_guests: %i[former_guest_loud],
      inactive_members: %i[inactive_member_loud],
      inactive_guests: %i[inactive_guest_loud]
    }
    expected = fixture_users(*(matrix[:current_members] + matrix[:current_guests])).uniq
    actual_ids = topics(:discussion_topic).members.pluck(:id)

    assert_equal expected.map(&:id).sort, actual_ids.sort
    assert_equal actual_ids.uniq, actual_ids, "members must not return duplicate users"
  end

  test "admins and guests match the fixture access matrix exactly" do
    topic = topics(:discussion_topic)

    assert_equal users(:admin, :guest_admin_normal).map(&:id).sort, topic.admins.pluck(:id).sort
    assert_equal users(
      :guest_quiet,
      :guest_normal,
      :guest_admin_normal,
      :guest_loud,
      :former_member_guest
    ).map(&:id).sort, topic.guests.pluck(:id).sort
  end

  test "direct topic admins and guests match the fixture access matrix exactly" do
    topic = topics(:direct_topic)

    assert_equal [ users(:guest_admin_normal).id ], topic.admins.pluck(:id)
    assert_equal users(
      :guest_quiet,
      :guest_normal,
      :guest_admin_normal,
      :guest_loud
    ).map(&:id).sort, topic.guests.pluck(:id).sort
  end

  test "group topic delivery scopes match the fixture access and volume matrix exactly" do
    quiet = fixture_users(:member_quiet, :guest_quiet, :reader_quiet)
    normal = fixture_users(
      :admin,
      :user,
      :member,
      :member_normal,
      :guest_normal,
      :guest_admin_normal,
      :reader_normal
    )
    loud = fixture_users(
      :member_loud,
      :guest_loud,
      :reader_loud,
      :member_guest_loud,
      :former_member_guest
    )
    expectations = {
      email_enabled_members: normal + loud,
      email_normal_members: normal,
      email_loud_members: loud,
      push_enabled_members: normal + fixture_users(:member_loud, :guest_quiet, :reader_quiet, :member_guest_loud, :former_member_guest),
      push_loud_members: fixture_users(:member_loud, :guest_quiet, :reader_quiet, :member_guest_loud, :former_member_guest)
    }

    assert_delivery_scope_matrix(topics(:discussion_topic), expectations)
    assert_empty topics(:discussion_topic).email_enabled_members.where(id: quiet)
    assert_empty topics(:discussion_topic).push_enabled_members.where(id: fixture_users(:member_quiet, :guest_loud, :reader_loud))
  end

  test "direct topic delivery scopes match the fixture access and volume matrix exactly" do
    quiet = fixture_users(:guest_quiet)
    normal = fixture_users(:guest_normal, :guest_admin_normal)
    loud = fixture_users(:guest_loud)
    expectations = {
      email_enabled_members: normal + loud,
      email_normal_members: normal,
      email_loud_members: loud,
      push_enabled_members: normal + fixture_users(:guest_quiet),
      push_loud_members: fixture_users(:guest_quiet)
    }

    assert_delivery_scope_matrix(topics(:direct_topic), expectations)
    assert_empty topics(:direct_topic).email_enabled_members.where(id: quiet)
    assert_empty topics(:direct_topic).push_enabled_members.where(id: loud)
  end

  private

  def fixture_users(*fixture_names)
    fixture_names.map { |fixture_name| users(fixture_name) }
  end

  def assert_delivery_scope_matrix(topic, expectations)
    expectations.each do |scope_name, expected|
      actual_ids = topic.public_send(scope_name).pluck(:id)
      assert_equal expected.map(&:id).sort, actual_ids.sort, scope_name
    end
  end
end
