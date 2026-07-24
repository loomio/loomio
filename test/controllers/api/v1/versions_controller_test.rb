require 'test_helper'

class Api::V1::VersionsControllerTest < ActionController::TestCase
  test "show returns version for comment" do
    user = users(:user)
    discussion = discussions(:discussion)
    comment = Comment.new(
      body: "Test comment",
      parent: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)

    sign_in user
    get :show, params: { comment_id: comment.id }
    assert_response :success
  end

  test "show hides voter identity and changes for anonymous poll stance versions" do
    admin = users(:admin)
    user = users(:user)
    discussion = discussions(:discussion)
    poll = PollService.create(params: {
      title: "Anon Poll",
      poll_type: "proposal",
      topic_id: discussion.topic.id,
      poll_option_names: ["Agree", "Disagree"],
      anonymous: true,
      closing_at: 5.days.from_now
    }, actor: admin)

    stance = poll.stances.find_by(participant: user) || poll.stances.first
    PaperTrail.request(whodunnit: user.id.to_s) do
      stance.update!(reason: "first")
      stance.update!(reason: "second")
    end
    assert stance.versions.any?, "expected a paper_trail version to exist"

    sign_in user
    get :show, params: { stance_id: stance.id, index: stance.versions.length - 1 }
    assert_response :success

    version = JSON.parse(response.body)['versions'].first
    assert_not version.key?('whodunnit'), "anonymous poll version must not expose whodunnit (voter id)"
    assert_not version.key?('object_changes'), "anonymous poll version must not expose object_changes (reason text)"
  end

  test "show returns forbidden for discarded comment" do
    user = users(:user)
    discussion = discussions(:discussion)
    comment = Comment.new(
      body: "Test comment",
      parent: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)
    CommentService.discard(comment: comment, actor: user)

    sign_in user
    get :show, params: { comment_id: comment.id }
    assert_response :forbidden
  end
end
