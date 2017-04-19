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
    @test_membership = @test_group.membership_for(@patrick)

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

    @test_comment = Comment.new(discussion: @test_discussion, body: 'I\'m rather likeable')
    @patrick.reload
    CommentService.create(comment: @test_comment, actor: @patrick)
    CommentService.like(comment: @test_comment, actor: @patrick)
    @test_like = CommentVote.find_or_create_by(comment_id: @test_comment.id, user_id: @patrick.id)


  end

  it 'updates user_id references from old to new' do
    @jennifer = User.create!(name: 'Jennifer Grey',
                             email: 'jennifer_grey@example.com',
                             username: 'jennifergrey',
                             password: 'gh0stmovie',
                             angular_ui_enabled: true)

    MigrateUserService.new(old_id: @patrick.id, new_id: @jennifer.id).commit!

    [@test_group,
     @test_membership,
     @test_discussion,
     @test_comment,
     @test_like,
     @test_proposal,
     @test_vote].each {|model| model.reload }

    assert_equal @test_group.creator, @jennifer
    assert_equal @test_membership.user, @jennifer
    assert_equal @test_discussion.author, @jennifer
    assert_equal @test_proposal.author, @jennifer
    assert_equal @test_vote.author, @jennifer
    assert_equal @test_comment.author, @jennifer
    assert_equal @test_like.author, @jennifer

    # create two votes then confirm that counts are recalculated
    # confirm counters across all models are reset

    # expect(discussion.author_id).to eq new_id
    # expect(vote.author_id).to eq new_id
    # expect(User.find(old_id).to raise_exception
    # expect(User.find(new_id).discussions).to include discussion
    # expect(service.migrate!).to change { User.count }.by(-1) # if user merge
    # assert that whodunit has changed on versions
  end
end
