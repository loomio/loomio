require 'test_helper'

class Api::V1::ReactionsControllerTest < ActionController::TestCase
  test "create likes the comment when authorized" do
    user = users(:normal_user)
    discussion = create_discussion(author: user, group: groups(:test_group))
    comment = Comment.new(
      body: "Test comment",
      discussion: discussion,
      author: user
    )
    CommentService.create(comment: comment, actor: user)
    
    reaction_params = {
      reaction: '+1',
      reactable_id: comment.id,
      reactable_type: 'Comment'
    }
    
    sign_in user
    post :create, params: { reaction: reaction_params }
    assert_response :success
  end

  test "create responds with error when user is unauthorized" do
    author = users(:discussion_author)
    discussion = create_discussion(author: author, group: groups(:test_group))
    comment = Comment.new(
      body: "Test comment",
      discussion: discussion,
      author: author
    )
    CommentService.create(comment: comment, actor: author)
    
    # Create a user who is NOT a member of the group
    unauthorized_user = User.create!(
      name: "Unauthorized User",
      email: "unauthorized@example.com",
      username: "unauthorized",
      encrypted_password: "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K",
      email_verified: true
    )
    
    reaction_params = {
      reaction: '+1',
      reactable_id: comment.id,
      reactable_type: 'Comment'
    }
    
    sign_in unauthorized_user
    post :create, params: { reaction: reaction_params }
    assert_response :forbidden
    assert_includes JSON.parse(response.body)['exception'], 'CanCan::AccessDenied'
  end

  test "index fetches reactions for multiple records at once" do
    user = users(:normal_user)
    group = groups(:test_group)
    discussion = create_discussion(author: user, group: group)
    
    comment = Comment.new(body: "Test comment", discussion: discussion, author: user)
    CommentService.create(comment: comment, actor: user)
    
    poll = Poll.new(
      title: "Test Poll",
      poll_type: "proposal",
      discussion: discussion,
      author: user,
      group: group
    )
    PollService.create(poll: poll, actor: user)
    
    outcome = Outcome.new(
      statement: "Test outcome",
      poll: poll,
      author: user
    )
    OutcomeService.create(outcome: outcome, actor: user)
    
    comment_reaction = Reaction.create!(user: user, reactable: comment, reaction: '+1')
    discussion_reaction = Reaction.create!(user: user, reactable: discussion, reaction: '+1')
    poll_reaction = Reaction.create!(user: user, reactable: poll, reaction: '+1')
    outcome_reaction = Reaction.create!(user: user, reactable: outcome, reaction: '+1')
    
    sign_in user
    get :index, params: {
      comment_ids: comment.id,
      discussion_ids: discussion.id,
      poll_ids: poll.id,
      outcome_ids: outcome.id
    }
    
    assert_equal 4, JSON.parse(response.body)['reactions'].length
  end

  test "index denies access correctly" do
    author = users(:discussion_author)
    discussion = create_discussion(author: author, group: groups(:test_group))
    
    comment = Comment.new(body: "Test comment", discussion: discussion, author: author)
    CommentService.create(comment: comment, actor: author)
    
    Reaction.create!(user: author, reactable: comment, reaction: '+1')
    Reaction.create!(user: author, reactable: discussion, reaction: '+1')
    
    # Create a user who is NOT a member of the group
    unauthorized_user = User.create!(
      name: "Unauthorized User 2",
      email: "unauthorized2@example.com",
      username: "unauthorized2",
      encrypted_password: "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K",
      email_verified: true
    )
    
    sign_in unauthorized_user
    get :index, params: { comment_ids: comment.id, discussion_ids: discussion.id }
    assert_response :forbidden
  end
end
