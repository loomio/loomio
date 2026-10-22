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

  test "create denies a former member even when a public poll retains their electorate record" do
    group = groups(:group)
    group.update!(is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    @poll.topic.group.reload
    @poll.topic.update!(private: false)
    MembershipService.revoke(membership: group.membership_for(@voter), actor: @voter)
    assert @poll.anonymous_poll_voters.exists?(voter: @voter)
    sign_in @voter

    post :create, params: {anonymous_ballot: {
      poll_id: @poll.id,
      anonymous_ballot_choices_attributes: [{poll_option_id: @poll.poll_options.first.id, score: 1}]
    }}

    assert_response :forbidden
    assert_empty @poll.anonymous_ballots
    assert_not @poll.anonymous_poll_voters.find_by!(voter: @voter).ballot_submitted?
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

  test "create rejects scalar ballots and mixed choice types without consuming the voter" do
    sign_in @voter
    invalid_payloads = [
      'not an object',
      { poll_id: @poll.id, anonymous_ballot_choices_attributes: [{ poll_option_id: @poll.poll_options.first.id, score: 1 }, 'not a choice'] }
    ]
    invalid_payloads.each do |payload|
      assert_no_difference ['AnonymousBallot.count', 'AnonymousBallotChoice.count'] do
        post :create, params: { anonymous_ballot: payload }, as: :json
      end

      assert_response :bad_request
      assert_not @poll.anonymous_poll_voters.find_by!(voter: @voter).reload.ballot_submitted?
    end
  end

  test "create rejects invalid scores without consuming the ballot" do
    sign_in @voter
    post :create, params: {
      anonymous_ballot: {
        poll_id: @poll.id,
        anonymous_ballot_choices_attributes: [
          { poll_option_id: @poll.poll_options.first.id, score: -1 }
        ]
      }
    }

    assert_response :unprocessable_entity
    assert_empty @poll.anonymous_ballots
    refute @poll.anonymous_poll_voters.find_by!(voter: @voter).ballot_submitted?
  end
end
