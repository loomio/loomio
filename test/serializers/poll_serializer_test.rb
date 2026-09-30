require "test_helper"

class PollSerializerTest < ActiveSupport::TestCase
  test "shared payloads omit anonymous voter state instead of reporting false" do
    voter = users(:user)
    poll = PollService.create(
      params: {
        title: "Detached anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: groups(:group).id,
        anonymous: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: users(:admin)
    )

    shared = PollSerializer.new(poll, scope: { exclude_types: [] }).as_json.fetch(:poll)
    assert_not shared.key?(:anonymous_voter_eligible)
    assert_not shared.key?(:anonymous_ballot_submitted)

    personal = PollSerializer.new(poll, scope: { exclude_types: [], current_user_id: voter.id }).as_json.fetch(:poll)
    assert_equal true, personal[:anonymous_voter_eligible]
    assert_equal false, personal[:anonymous_ballot_submitted]
  end
end
