require "test_helper"
require_relative "ability_contract_helper"

# Server answers for vote changes and redaction, checked against the client's
# StanceAbility by vue/tests/component/stance_ability_contract.test.js.
class StanceAbilityContractTest < ActiveSupport::TestCase
  include AbilityContractHelper

  ACTIONS = %i[update uncast redact unredact].freeze
  STANCE_FIELDS = %i[latest revoked_at cast_at redacted_at participant_id reason].freeze
  POLL_FIELDS = %w[closed_at closing_at opened_at opening_at discarded_at hide_results anonymous voter_has_access].freeze

  test "writes the stance ability contract for the client" do
    cases = travel_to(CONTRACT_TIME) do
      TOPICS.product(%w[open closed]).flat_map { |topic_name, state| cases_for(topics(topic_name), topic_name, state) }
    end
    write_ability_contract("stance_abilities", cases)
  end

  private

  def cases_for(topic, topic_name, state)
    coordinator = topic.admins.order(:id).first!
    topic.update_columns(polls_one_at_a_time: false)
    poll = PollService.create(params: {
      title: "Stance contract", poll_type: "proposal", poll_option_names: %w[Agree Disagree],
      closing_at: 3.days.from_now, topic_id: topic.id, notify_on_open: false
    }, actor: coordinator)
    poll.stances.latest.update_all(cast_at: 1.hour.ago, reason: "A reason")
    poll.stances.latest.where.not(participant_id: coordinator.id).update_all(cast_at: nil, reason: nil)
    PollService.close(poll: poll, actor: coordinator) if state == "closed"
    other = poll.stances.latest.find_by!(participant_id: coordinator.id)

    ROLES.flat_map do |role|
      user = users(role)
      own = poll.stances.latest.find_by(participant_id: user.id)
      subjects = []
      subjects << ["other", other] unless own == other
      if own
        subjects << ["own uncast", -> { own.update_columns(cast_at: nil, reason: nil) }]
        subjects << ["own cast", -> { own.update_columns(cast_at: 1.hour.ago, reason: "Mine") }]
        subjects << ["own redacted", -> { own.update_columns(redacted_at: 1.minute.ago) }]
        subjects << ["own revoked", -> { own.update_columns(redacted_at: nil, revoked_at: 1.minute.ago) }]
      end

      subjects.filter_map do |label, subject|
        if subject.respond_to?(:call)
          subject.call
          subject = own
        end
        snapshot("#{role} #{topic_name} #{state} poll #{label} stance", topic, user, poll, subject.reload, own&.reload)
      end
    end
  end

  def snapshot(name, topic, user, poll, stance, own)
    serialized = PollSerializer.new(poll.reload, scope: {current_user_id: user.id}).as_json.fetch(:poll).stringify_keys
    {
      name: name,
      roles: role_facts(user, topic).merge(poll_admin: poll.admins.exists?(user.id)),
      poll: serialized.slice(*POLL_FIELDS).merge("my_stance_id" => own&.id),
      stance: raw(stance, STANCE_FIELDS).merge("id" => stance.id),
      my_stance: own && raw(own, %i[cast_at revoked_at]).merge("id" => own.id),
      expected: answers(user, stance, ACTIONS)
    }
  end
end
