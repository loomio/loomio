# Observe the shared fixture matrix through fresh queries so cleanup tests catch
# changes to effective access and recipient sets, not just surviving row IDs.
# TopicTest and GroupTest independently pin the exact baseline recipient sets.
module AccessVolumeMatrix
  ROLES = %i[
    admin user member member_quiet member_normal member_loud
    guest_quiet guest_normal guest_admin_normal guest_loud
    alien alien_quiet alien_loud non_guest_loud former_member_loud
    former_guest_loud inactive_member_loud inactive_guest_loud
    reader_quiet reader_normal reader_loud member_guest_loud former_member_guest
  ].freeze
  TOPICS = %i[discussion_topic direct_topic public_discussion_topic].freeze

  def access_volume_matrix
    result = {}
    TOPICS.each do |name|
      topic = Topic.find(topics(name).id)
      %i[members admins guests email_enabled_members email_normal_members email_loud_members push_enabled_members push_loud_members].each do |scope|
        result[[ name, scope ]] = topic.public_send(scope).pluck(:id).sort
      end
      ROLES.each do |role|
        user = User.find(users(role).id)
        result[[ name, role, :can_show ]] = user.can?(:show, topic.topicable)
        reader = TopicReader.for(user: user, topic: topic)
        result[[ name, role, :volume ]] = [ reader.computed_volume_email, reader.computed_volume_push ]
      end
      result[[ name, :signed_out ]] = LoggedOutUser.new.can?(:show, topic.topicable)
    end
    %i[group alien_group public_group].each do |name|
      group = Group.find(groups(name).id)
      %i[members admins email_enabled_members email_loud_members push_enabled_members push_loud_members].each do |scope|
        result[[ name, scope ]] = group.public_send(scope).pluck(:id).sort
      end
    end
    result
  end

  def assert_access_volume_matrix_unchanged(before)
    after = access_volume_matrix
    assert_equal before.keys, after.keys
    before.each { |key, expected| assert_equal expected, after.fetch(key), key.join(" / ") }
  end
end
