require 'rails_helper'

describe MigrateUserService do
  before do
    @patrick = User.create!(name: 'Patrick Swayze',
                            email: 'patrick_swayze@example.com',
                            is_admin: true,
                            username: 'patrickswayze',
                            password: 'gh0stmovie',
                            detected_locale: 'en',
                            angular_ui_enabled: true)

    @test_group = Group.create!(name: 'Dirty Dancing Shoes',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private',
                                creator: @patrick)

    @test_group.add_admin! @patrick

    @test_discussion = Discussion.create(title: 'What star sign are you?',
                                         private: false,
                                         group: @test_group,
                                         author: @patrick)

    DiscussionService.create(discussion: @test_discussion, actor: @test_discussion.author)

    @test_proposal = Motion.new(name: 'lets go hiking to the moon and never ever ever come back!',
                                closing_at: 3.days.from_now.beginning_of_hour,
                                discussion: @test_discussion)

    MotionService.create(motion: @test_proposal, actor: @patrick)

    @test_vote = Vote.new(position: 'yes', motion: @test_proposal, statement: 'I agree!')
    VoteService.create(vote: @test_vote, actor: @patrick)

    # @comment = Comment.new(discussion: @test_discussion, body: 'I\'m rather likeable')
    # CommentService.create(comment: @comment, actor: @patrick)
    # @comment_liked_event = CommentService.like(comment: @comment, actor: @patrick)
  end

  it 'updates user_id references from old to new' do
    # author a discussion
    # author a motion
    # author a comment
    # author a like
    # author a vote
    # create a group
    # join a group
    @jennifer = User.create!(name: 'Jennifer Grey',
                             email: 'jennifer_grey@example.com',
                             username: 'jennifergrey',
                             password: 'gh0stmovie',
                             angular_ui_enabled: true)

    MigrateUserService.new(old_id: @patrick.id, new_id: @jennifer.id).commit!

    

    # create a new user
    # migrate old to new

    # verify that new user is the author, creator and member now.
  end
end
