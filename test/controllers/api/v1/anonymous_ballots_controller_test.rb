require "test_helper"

class Api::V1::AnonymousBallotsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @voter = users(:user)
    @poll = PollService.create(
      params: {
        title: "Anonymous controller poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: groups(:group).id,
        anonymous: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: @admin
    )
  end

  test "create acknowledges submission without returning the ballot or choices" do
    sign_in @voter
    post :create, params: {
      anonymous_ballot: {
        poll_id: @poll.id,
        anonymous_ballot_choices_attributes: [
          { poll_option_id: @poll.poll_options.first.id, score: 1 }
        ]
      }
    }

    assert_response :success
    assert_equal({ "recorded" => true }, JSON.parse(response.body))
  end

  test "create rejects reasons and attachments" do
    sign_in @voter
    post :create, params: {
      anonymous_ballot: {
        poll_id: @poll.id,
        reason: "identify me",
        files: ["secret"],
        anonymous_ballot_choices_attributes: [
          { poll_option_id: @poll.poll_options.first.id, score: 1 }
        ]
      }
    }

    assert_response :bad_request
    assert_empty @poll.anonymous_ballots
  end

  test "create denies an ineligible user" do
    outsider = users(:alien)
    sign_in outsider

    post :create, params: {
      anonymous_ballot: {
        poll_id: @poll.id,
        anonymous_ballot_choices_attributes: [
          { poll_option_id: @poll.poll_options.first.id, score: 1 }
        ]
      }
    }

    assert_response :forbidden
    assert_empty @poll.anonymous_ballots
  end

  test "create rejects malformed nested choice parameters" do
    sign_in @voter
    post :create, params: {
      anonymous_ballot: {
        poll_id: @poll.id,
        anonymous_ballot_choices_attributes: {
          "0" => { poll_option_id: @poll.poll_options.first.id }
        }
      }
    }

    assert_response :bad_request
    assert_empty @poll.anonymous_ballots
  end
end
