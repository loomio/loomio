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

    @jennifer = User.create!(name: 'Jennifer Grey',
                             email: 'jennifer_grey@example.com',
                             is_admin: true,
                             username: 'jennifergrey',
                             password: 'gh0stmovie',
                             detected_locale: 'en',
                             angular_ui_enabled: true)

    @visit = Visit.create(user_id: @patrick.id, id: SecureRandom.uuid)

    @ahoy_event = Ahoy::Event.create(id: SecureRandom.uuid,
                                     visit_id: @visit.id,
                                     user_id: @patrick.id)

    @ahoy_message = Ahoy::Message.create(user_id: @patrick.id)

    @group = Group.create!(name: 'Dirty Dancing Shoes',
                                group_privacy: 'closed',
                                discussion_privacy_options: 'public_or_private',
                                creator: @patrick)

    @group.add_admin! @patrick

    @discussion = Discussion.create(title: 'What star sign are you?',
                                         private: false,
                                         group: @group,
                                         author: @patrick)

    DiscussionService.create(discussion: @discussion, actor: @discussion.author)

    @discussion.update(description: 'New version')

    PaperTrail::Version.update_all(whodunnit: "#{@patrick.id}")

    @comment = Comment.new(discussion: @discussion, body: 'I\'m rather likeable')
    @jcomment = FactoryGirl.build(:comment, user: @jennifer, body: 'Hullo, @patrickswayze', discussion: @discussion)
    CommentService.create(comment: @comment, actor: @jennifer)
    @patrick.reload
    CommentService.create(comment: @comment, actor: @patrick)
    CommentService.like(comment: @comment, actor: @patrick)
    @like = CommentVote.find_or_create_by(comment_id: @comment.id, user_id: @patrick.id)

    @motion = Motion.new(name: 'lets go hiking to the moon and never ever ever come back!',
                                closing_at: 3.days.from_now.beginning_of_hour,
                                discussion: @discussion)

    MotionService.create(motion: @motion, actor: @patrick)

    @motion.update(outcome: 'Shoutcome', outcome_author_id: @patrick.id)

    @vote = Vote.new(position: 'yes', motion: @motion, statement: 'I agree!')
    VoteService.create(vote: @vote, actor: @patrick)

    # @attachment = Attachment.create(file: fixture_for('images', 'strongbad.png'),
    #                                 user_id: @patrick.id)

    @contact = Contact.create(name: Faker::Name.name,
                              email: Faker::Internet.email,
                              source: 'fakesores',
                              user_id: @patrick.id)

    @discussion_reader = DiscussionReader.for(discussion: @discussion, user: @patrick)

    @draft = Draft.create(user_id: @patrick.id, draftable: @discussion)

    @invitation = Invitation.create(inviter_id: @patrick.id, invitable: @group, intent: 'start_group')

    @membership_request = FactoryGirl.create(:membership_request, requestor: @patrick)

    @notification = Notification.last

    @omniauth_identity = OmniauthIdentity.create(user: @patrick, uid: 1, provider: 'fake')

    @user_deactivation_response = UserDeactivationResponse.create(user_id: @patrick.id, body: 'goodbye')

    @group.add_admin! @jennifer
    @jvote = Vote.new(position: 'no', motion: @motion, statement: 'I disagree!')
    VoteService.create(vote: @vote, actor: @jennifer)

  end

  it 'updates user_id references from old to new' do

    MigrateUserService.new(old_id: @patrick.id, new_id: @jennifer.id).commit!
    @membership = @group.membership_for(@jennifer)

    [@visit,
     @ahoy_event,
     @ahoy_message,
     @group,
     @membership,
     @discussion,
     @comment,
     @like,
     @motion,
     @vote,
    #  @attachment,
     @contact,
     @discussion_reader,
     @draft,
     @invitation,
     @membership_request,
     @omniauth_identity,
     @user_deactivation_response].each {|model| model.reload }

    assert_equal @visit.user_id, @jennifer.id
    assert_equal @ahoy_event.user_id, @jennifer.id
    assert_equal @ahoy_message.user_id, @jennifer.id
    assert_equal @group.creator, @jennifer
    assert_equal @membership.user, @jennifer
    assert_equal @discussion.author, @jennifer
    assert_equal @comment.author, @jennifer
    assert_equal @like.author, @jennifer
    assert_equal @motion.author, @jennifer
    assert_equal @motion.outcome_author, @jennifer
    assert_equal @vote.author, @jennifer
    # assert_equal @attachment.user_id, @jennifer.id
    assert_equal @contact.user_id, @jennifer.id
    assert_equal @discussion_reader.user_id, @jennifer.id
    assert_equal @draft.user_id, @jennifer.id
    assert_equal @invitation.inviter, @jennifer
    assert_equal @membership_request.requestor, @jennifer
    assert_equal @omniauth_identity.user, @jennifer
    assert_equal @user_deactivation_response.user_id, @jennifer.id
    assert_equal 1, @motion.votes_count
    assert_equal 1, @motion.voters_count
    assert_equal 1, @group.memberships_count
    assert_equal 1, @group.admin_memberships_count
    assert_equal @jennifer.id, @discussion.versions.last.whodunnit.to_i
    expect(User.find_by_id(@patrick.id)).to be nil
  end
end
