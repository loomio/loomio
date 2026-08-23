require 'test_helper'

class Api::V1::ReactionsControllerTest < ActionController::TestCase
  test "create likes the comment when authorized" do
    user = users(:admin)
    discussion = discussions(:discussion)
    comment = Comment.new(
      body: "Test comment",
      parent: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)

    reaction_params = {
      reaction: '👍',
      reactable_id: comment.id,
      reactable_type: 'Comment'
    }

    sign_in user
    post :create, params: { reaction: reaction_params }
    assert_response :success
  end

  test "create responds with error when user is unauthorized" do
    author = users(:admin)
    discussion = discussions(:discussion)
    comment = Comment.new(
      body: "Test comment",
      parent: discussion,
      author: author
    )
    CommentService.create(comment: comment, actor: author)

    # Create a user who is NOT a member of the group
    unauthorized_user = User.create!(
      name: "Unauthorized User",
      email: "unauthorized@example.com",
      username: "unauthorized",
      password_digest: "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K",
      email_verified: true
    )

    reaction_params = {
      reaction: '👍',
      reactable_id: comment.id,
      reactable_type: 'Comment'
    }

    sign_in unauthorized_user
    post :create, params: { reaction: reaction_params }
    assert_response :forbidden
  end

  test "create rejects reactable types outside the allowlist" do
    user = users(:admin)

    sign_in user
    post :create, params: { reaction: { reaction: '👍', reactable_id: user.id, reactable_type: 'User' } }

    assert_response :not_found
  end

  test "index fetches reactions for multiple records at once" do
    user = users(:admin)
    group = groups(:group)
    discussion = discussions(:discussion)

    comment = Comment.new(body: "Test comment", parent: discussion, author: user)
    CommentService.create(comment: comment, actor: user)

    poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      topic_id: discussion.topic.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: %w[agree disagree]
    }, actor: user)
    poll.update!(closed_at: 1.day.ago)

    outcome = Outcome.new(
      statement: "Test outcome",
      poll: poll,
      author: user
    )
    OutcomeService.create(outcome: outcome, actor: user)

    comment_reaction = Reaction.create!(user: user, reactable: comment, reaction: '👍')
    discussion_reaction = Reaction.create!(user: user, reactable: discussion, reaction: '👍')
    poll_reaction = Reaction.create!(user: user, reactable: poll, reaction: '👍')
    outcome_reaction = Reaction.create!(user: user, reactable: outcome, reaction: '👍')

    sign_in user
    get :index, params: {
      comment_ids: comment.id,
      discussion_ids: discussion.id,
      poll_ids: poll.id,
      outcome_ids: outcome.id
    }

    assert_equal 4, JSON.parse(response.body)['reactions'].length
  end

  test "index fetches reactions for comments on a poll" do
    user = users(:admin)
    group = groups(:group)
    poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      group_id: group.id,
      specified_voters_only: true,
      closing_at: 5.days.from_now,
      poll_option_names: %w[agree disagree]
    }, actor: user)
    comment = Comment.new(body: "Test poll comment", parent: poll, author: user)
    CommentService.create(comment: comment, actor: user)
    Reaction.create!(user: user, reactable: comment, reaction: '👍')

    sign_in user
    get :index, params: { comment_ids: comment.id }

    assert_response :success
    assert_equal 1, JSON.parse(response.body)['reactions'].length
  end

  test "index fetches reactions for edited comments" do
    user = users(:admin)
    discussion = discussions(:discussion)
    comment = Comment.new(body: "Test comment", parent: discussion, author: user)
    CommentService.create(comment: comment, actor: user)
    CommentService.update(comment: comment, params: { body: "Edited comment" }, actor: user)
    Reaction.create!(user: user, reactable: comment, reaction: '👍')

    assert_not comment.topic_items.where(kind: "comment_edited").exists?

    sign_in user
    get :index, params: { comment_ids: comment.id }

    assert_response :success
    assert_equal 1, JSON.parse(response.body)['reactions'].length
  end

  test "destroy removes the reaction topic_item" do
    user = users(:admin)
    comment = Comment.new(body: 'Reactable comment', parent: discussions(:discussion), author: user)
    CommentService.create(comment: comment, actor: user)
    reaction = Reaction.create!(user: user, reactable: comment, reaction: '👍')
    topic_item = TopicItem.create!(kind: 'reaction_created', itemable: reaction, user: user, topic: comment.topic)

    sign_in user
    delete :destroy, params: { id: reaction.id }

    assert_response :success
    refute TopicItem.exists?(topic_item.id)
  end

  test "create denied when allow_reactions is false" do
    user = users(:admin)
    discussion = discussions(:discussion)
    comment = Comment.new(body: "Test comment", parent: discussion, author: user)
    CommentService.create(comment: comment, actor: user)

    discussion.topic.update!(allow_reactions: false)

    sign_in user
    post :create, params: { reaction: { reaction: '👍', reactable_id: comment.id, reactable_type: 'Comment' } }
    assert_response :forbidden
  end

  test "index filters inaccessible discussions and comments from a mixed batch" do
    user = users(:admin)
    inaccessible_user = users(:alien)
    discussion = discussions(:discussion)
    inaccessible_discussion = discussions(:alien_discussion)
    comment = Comment.new(body: "Visible comment", parent: discussion, author: user)
    inaccessible_comment = Comment.new(
      body: "Inaccessible comment",
      parent: inaccessible_discussion,
      author: inaccessible_user
    )
    CommentService.create(comment: comment, actor: user)
    CommentService.create(comment: inaccessible_comment, actor: inaccessible_user)

    reactions_visible = [
      Reaction.create!(user: user, reactable: comment, reaction: '👍'),
      Reaction.create!(user: user, reactable: discussion, reaction: '👍')
    ]
    Reaction.create!(user: inaccessible_user, reactable: inaccessible_comment, reaction: '👍')
    Reaction.create!(user: inaccessible_user, reactable: inaccessible_discussion, reaction: '👍')

    sign_in user
    get :index, params: {
      comment_ids: [comment.id, inaccessible_comment.id].join('x'),
      discussion_ids: [discussion.id, inaccessible_discussion.id].join('x')
    }

    assert_response :success
    assert_equal reactions_visible.map(&:id).sort, response_reaction_ids
  end

  test "index filters inaccessible polls outcomes and stances from a mixed batch" do
    user = users(:admin)
    inaccessible_user = users(:alien)
    poll = create_poll(topic: discussions(:discussion).topic, actor: user)
    inaccessible_poll = create_poll(topic: discussions(:alien_discussion).topic, actor: inaccessible_user)
    outcome = create_outcome(poll: poll, actor: user)
    inaccessible_outcome = create_outcome(poll: inaccessible_poll, actor: inaccessible_user)
    stance = create_stance(poll: poll, actor: user)
    inaccessible_stance = create_stance(poll: inaccessible_poll, actor: inaccessible_user)

    reactions_visible = [poll, outcome, stance].map do |reactable|
      Reaction.create!(user: user, reactable: reactable, reaction: '👍')
    end
    [inaccessible_poll, inaccessible_outcome, inaccessible_stance].each do |reactable|
      Reaction.create!(user: inaccessible_user, reactable: reactable, reaction: '👍')
    end

    sign_in user
    get :index, params: {
      poll_ids: [poll.id, inaccessible_poll.id].join('x'),
      outcome_ids: [outcome.id, inaccessible_outcome.id].join('x'),
      stance_ids: [stance.id, inaccessible_stance.id].join('x')
    }

    assert_response :success
    assert_equal reactions_visible.map(&:id).sort, response_reaction_ids
  end

  test "index only returns public reactions to signed out users" do
    user = users(:admin)
    discussion = discussions(:public_discussion)
    inaccessible_discussion = discussions(:discussion)
    reactions_visible = [Reaction.create!(user: user, reactable: discussion, reaction: '👍')]
    Reaction.create!(user: user, reactable: inaccessible_discussion, reaction: '👍')

    get :index, params: { discussion_ids: [discussion.id, inaccessible_discussion.id].join('x') }

    assert_response :success
    assert_equal reactions_visible.map(&:id), response_reaction_ids
  end

  test "index filters other participants' stance reactions while results are hidden" do
    user = users(:admin)
    participant = users(:user)
    poll = create_poll(topic: discussions(:discussion).topic, actor: user)
    poll.update!(hide_results: 'until_closed')
    stance = create_stance(poll: poll, actor: user)
    inaccessible_stance = create_stance(poll: poll, actor: participant)
    reaction_visible = Reaction.create!(user: user, reactable: stance, reaction: '👍')
    Reaction.create!(user: participant, reactable: inaccessible_stance, reaction: '👍')

    sign_in user
    get :index, params: { stance_ids: [stance.id, inaccessible_stance.id].join('x') }

    assert_response :success
    assert_equal [reaction_visible.id], response_reaction_ids
  end

  private

  def create_poll(topic:, actor:)
    PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      topic_id: topic.id,
      closing_at: 5.days.from_now,
      poll_option_names: %w[agree disagree]
    }, actor: actor)
  end

  def create_outcome(poll:, actor:)
    poll.update!(closed_at: 1.day.ago)
    outcome = Outcome.new(statement: "Test outcome", poll: poll, author: actor)
    OutcomeService.create(outcome: outcome, actor: actor)
    outcome
  end

  def create_stance(poll:, actor:)
    stance = poll.stances.latest.find_or_initialize_by(participant: actor)
    stance.assign_attributes(
      cast_at: Time.current,
      stance_choices_attributes: [{ poll_option_id: poll.poll_options.first.id }]
    )
    stance.save!
    stance
  end

  def response_reaction_ids
    JSON.parse(response.body)['reactions'].pluck('id').sort
  end
end
