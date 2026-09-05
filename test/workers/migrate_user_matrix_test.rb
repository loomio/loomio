require "test_helper"
require_relative "../support/access_volume_matrix"

class MigrateUserMatrixTest < ActiveSupport::TestCase
  include AccessVolumeMatrix

  # Duplicate memberships/readers currently keep the destination's role,
  # revocation and channel preferences. These cases pin that existing rule;
  # they must not silently combine privileges or inherit the louder setting.
  [
    %i[member_loud member_quiet],
    %i[reader_quiet reader_loud],
    %i[guest_loud guest_quiet],
    %i[guest_admin_normal guest_normal],
    %i[former_guest_loud guest_loud],
    %i[guest_loud former_guest_loud],
    %i[inactive_guest_loud guest_normal]
  ].each do |source_role, destination_role|
    test "#{source_role} into #{destination_role} retains destination access and channel preferences" do
      source = users(source_role)
      destination = users(destination_role)
      before = access_volume_matrix
      memberships = destination.all_memberships.order(:id).map(&:attributes)
      readers = destination.topic_readers.order(:id).map(&:attributes)
      defaults = destination.attributes.slice("volume_email_default", "volume_push_default")
      source_session = source.sessions.create!(user_agent: "Source browser", ip_address: "127.0.0.1")
      destination_session = destination.sessions.create!(user_agent: "Destination browser", ip_address: "127.0.0.1")
      source_token = LoginToken.create!(user: source)
      destination_token = LoginToken.create!(user: destination)

      MigrateUserWorker.new.perform(source.id, destination.id)

      assert_equal memberships, destination.all_memberships.reload.order(:id).map(&:attributes)
      assert_equal readers, destination.topic_readers.reload.order(:id).map(&:attributes)
      assert_equal defaults, destination.reload.attributes.slice("volume_email_default", "volume_push_default")
      assert_nil source.reload.email
      assert_not Session.exists?(source_session.id)
      assert_not LoginToken.exists?(source_token.id)
      assert_equal destination.id, destination_session.reload.user_id
      assert_equal destination.id, destination_token.reload.user_id

      # Both roles already have records at these boundaries. Only the source
      # leaves the audience; destination and unrelated users keep their access.
      after = access_volume_matrix
      before.each do |key, expected|
        next if key.include?(source_role)

        expected = expected - [ source.id ] if expected.is_a?(Array)
        assert_equal expected, after.fetch(key), key.join(" / ")
      end
    end
  end

  test "source-only guest readers move with their exact role and mixed channel preferences" do
    source = users(:guest_quiet)
    destination = users(:member_quiet)
    reader = TopicReader.find_by!(topic: topics(:direct_topic), user: source)
    reader_before = reader.attributes
    assert_not TopicReader.exists?(topic: topics(:direct_topic), user: destination)

    MigrateUserWorker.new.perform(source.id, destination.id)

    assert_equal reader_before.merge("user_id" => destination.id), reader.reload.attributes
    topic = Topic.find(topics(:direct_topic).id)
    assert destination.reload.can?(:show, topic.topicable)
    assert_not_includes topic.email_enabled_members, destination
    assert_includes topic.push_loud_members, destination
    assert_not source.reload.can?(:show, topic.topicable)
  end
end
