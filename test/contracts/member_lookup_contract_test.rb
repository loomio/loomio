require "test_helper"
require_relative "ability_contract_helper"

# Server answers for who counts as a group, thread and poll admin or member,
# together with the payloads the client receives for that user.
# vue/tests/component/member_lookup_contract.test.js imports each payload into
# the real record store and checks the client models' adminsInclude and
# membersInclude against these answers.
class MemberLookupContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  LOOKUP_ROLES = (ROLES + %i[former_guest_loud member_guest_loud former_member_guest non_guest_loud]).freeze

  test "writes the member lookup contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      TOPICS.product(%w[private public public_revoked]).flat_map do |topic_name, visibility|
        next [] if visibility.start_with?("public") && !topics(topic_name).group_id
        cases_for(topic_name, visibility)
      end
    end
    write_ability_contract("member_lookups", cases)
  end

  private

  def cases_for(topic_name, visibility)
    topic = Topic.find(topics(topic_name).id)
    if visibility.start_with?("public")
      topic.group.update_columns(is_visible_to_public: true, discussion_privacy_options: "public_or_private")
      topic.update_columns(private: false)
    end
    # Revoking a guest, as Api::V1::TopicReadersController#revoke does, keeps
    # the reader's guest and admin flags.
    topic.topic_readers.where(guest: true).update_all(revoked_at: 1.hour.ago) if visibility == "public_revoked"
    poll = poll_with_every_role_voting(topic)

    LOOKUP_ROLES.filter_map do |role|
      user = users(role)
      # The client only holds threads it can see.
      next unless user.can?(:show, topic.topicable)

      {
        name: "#{role} #{topic_name} #{visibility}",
        roles: role_facts(user, topic),
        payload: payload_for(user, topic, poll),
        topic_id: topic.id,
        poll_id: poll.id,
        expected: {
          group_admin: topic.group_id.present? && topic.group.admins_include?(user),
          group_member: topic.group_id.present? && topic.group.members_include?(user),
          topic_admin: topic.admins_include?(user),
          topic_member: topic.members_include?(user),
          poll_admin: poll.admins.exists?(user.id),
          poll_member: poll.members.exists?(user.id)
        }
      }
    end
  end

  # Revoked guests can keep an unrevoked vote, so every role holds one.
  def poll_with_every_role_voting(topic)
    poll = PollService.create(params: {
      title: "Lookup contract", poll_type: "proposal", poll_option_names: %w[Agree Disagree],
      closing_at: 3.days.from_now, topic_id: topic.id, notify_on_open: false
    }, actor: topic.admins.order(:id).first!)
    LOOKUP_ROLES.each do |role|
      user = users(role)
      next if poll.stances.latest.exists?(participant_id: user.id)
      poll.stances.create!(participant: user, inviter: poll.author, latest: true, reason_format: "html")
    end
    poll.reload
  end

  def payload_for(user, topic, poll)
    scope = ->(records) { {cache: RecordCache.for_collection(records, user.id, []), current_user_id: user.id, exclude_types: []} }
    serialize = ->(records, serializer, root) {
      ActiveModel::ArraySerializer.new(records, each_serializer: serializer, root: root, scope: scope.call(records)).as_json
    }
    [
      Boot::User.new(user, root_url: "/").payload.except(:current_user_id, :pending_identity, :flash, :root_url),
      serialize.call([topic], TopicSerializer, :topics),
      serialize.call([poll], PollSerializer, :polls),
      serialize.call(poll.stances.latest.where(participant_id: user.id).to_a, StanceSerializer, :stances)
    ].reduce({}) { |merged, part| merged.merge(part.as_json) { |_key, a, b| a.is_a?(Array) ? (a + b).uniq : b } }
  end
end
