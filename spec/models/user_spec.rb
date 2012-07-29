require 'spec_helper'

describe User do
  let(:user) { User.make! }

  subject do
    user = User.new
    user.valid?
    user
  end

  it { should have(1).errors_on(:name) }

  it "must have a valid email" do
    user = User.new
    user.email = '"Joe Gumby" <joe@gumby.com>'
    user.valid?
    user.should have(1).errors_on(:email)
  end

  it "has uploaded avatar less than 1000kb "

  it "email can have an apostrophe" do
    user = User.new
    user.email = "mr.d'arcy@gumby.com"
    user.valid?
    user.should have(0).errors_on(:email)
  end

  it "has many groups" do
    group = Group.make!
    group.add_member!(user)
    user.groups.should include(group)
  end

  it "has many adminable_groups" do
    group = Group.make!
    group.add_admin!(user)
    user.adminable_groups.should include(group)
  end

  it "has many admin memberships" do
    group = Group.make!
    membership = group.add_admin!(user)
    user.admin_memberships.should include(membership)
  end

  it "has correct group request" do
    group = Group.make!
    Membership.make!(:group => group, :user => user)
    user.group_requests.should include(group)
  end

  it "has authored discussions" do
    group = Group.make!
    group.add_member!(user)
    discussion = Discussion.new(:group => group, :title => "Hello world")
    discussion.author = user
    discussion.save!
    user.authored_discussions.should include(discussion)
  end

  it "has authored motions" do
    group = Group.make!
    group.add_member!(user)
    discussion = create_discussion(group: group)
    motion = create_motion(discussion: discussion, author: user)
    user.authored_motions.should include(motion)
  end

  describe "motions_in_voting_phase" do
    it "should return motions that belong to user and are in phase 'voting'" do
      motion = create_motion(author: user)
      user.motions_in_voting_phase.should include(motion)
    end

    it "should not return motions that belong to the group but are in phase 'closed'" do
      motion = create_motion(author: user)
      motion.close_voting!
      user.motions_in_voting_phase.should_not include(motion)
    end
  end

  describe "motions_closed" do
    it "should return motions that belong to the group and are in phase 'voting'" do
      motion = create_motion(author: user)
      motion.close_voting!
      user.motions_closed.should include(motion)
    end

    it "should not return motions that belong to the group but are in phase 'closed'" do
      motion = create_motion(author: user)
      user.motions_closed.should_not include(motion)
    end
  end

  describe "motions_in_voting_phase_that_user_has_voted_on" do
    it "calls scope on motions_in_voting_phase" do
      user.motions_in_voting_phase.should_receive(:that_user_has_voted_on).
        with(user).and_return(stub(:uniq => true))

      user.motions_in_voting_phase_that_user_has_voted_on
    end
  end

  describe "motions_in_voting_phase_that_user_has_not_voted_on" do
    it "does stuff " do
      user.should_receive(:motions_in_voting_phase_that_user_has_not_voted_on)

      user.motions_in_voting_phase_that_user_has_not_voted_on
    end
  end

  describe "user.discussions_sorted_paged" do
    it "returns a list of discussions sorted by last_comment_at" do
      discussion1 = create_discussion :author => user
      discussion2 = create_discussion :author => user
      discussion2.add_comment user, "hi"
      discussion3 = create_discussion :author => user
      discussion4 = create_discussion :author => user
      discussion1.add_comment user, "hi"
      user.discussions_sorted[0].should == discussion1
      user.discussions_sorted[1].should == discussion4
      user.discussions_sorted[2].should == discussion3
      user.discussions_sorted[3].should == discussion2
    end
  end

  describe "user.voted?(motion)" do
    before do
      group = Group.make!
      group.add_member!(user)
      discussion = create_discussion(group: group)
      @motion = create_motion(discussion: discussion, author: user)
    end
    it "it returns true if user has voted on motion" do
      vote = user.votes.new(position: "abstain")
      vote.motion = @motion
      vote.save!
      user.voted?(@motion).should == true
    end
    it "it returns false if user has not voted on motion" do
      user.voted?(@motion).should == false
    end
  end

  it "can be invited" do
    inviter = User.make!
    group = Group.make!
    user = User.invite_and_notify!({email: "foo@example.com"}, inviter, group)
    group.users.should include(user)
  end

  it "invited user should have email as name" do
    user = User.invite_and_notify!({email: "foo@example.com"}, User.make!, Group.make!)
    user.name.should == user.email
  end

  it "can find user by email (case-insensitive)" do
    user = User.make!(email: "foobar@example.com")
    User.find_by_email("foObAr@exaMPLE.coM").should == user
  end

  it "can create a new motion_read_log" do
    @group = Group.make!
    @discussion = create_discussion(group: @group)
    user.update_discussion_read_log(@discussion)
    DiscussionReadLog.count.should == 1
  end

  it "can update an existing motion_read_log" do
    @group = Group.make!
    @discussion = create_discussion(group: @group)
    @discussion.activity = 4
    user.update_discussion_read_log(@discussion)
    @discussion.activity = 5
    user.discussion_activity_when_last_read(@discussion).should == 4
    user.update_discussion_read_log(@discussion)
    user.discussion_activity_when_last_read(@discussion).should == 5
  end

  describe "name" do
    it "returns 'Deleted User' if deleted_at is true (a date is present)" do
      user.update_attribute(:deleted_at, 1.month.ago)
      user.name.should == 'Deleted user'
    end

    it "returns the stored name if deleted_at is nil" do
      user.name.should_not == 'Deleted user'
    end
  end

  describe "initials" do
    it "returns 'DU' if deleted_at is true (a date is present)"
    it "returns the stored name initials in all caps if deleted_at is nil"
    it "returns the first two characters in all caps of the email if the user's name is email and if deleted_at is nil"

  end

  describe "avatar_url" do
    it "returns gravatar url if avatar_kind is 'gravatar'" do
      user.stub(:gravatar_url).and_return('www.gravatar/spike')
      user.avatar_kind = 'gravatar'
      user.avatar_url.should == 'www.gravatar/spike'
    end
    it "returns uploaded url if avatar_kind is 'uploaded'" do
      user.stub_chain(:uploaded_avatar, :url).and_return('www.gravatar/uploaded/mike')
      user.avatar_kind = 'uploaded'
      user.avatar_url.should == 'www.gravatar/uploaded/mike'
    end
    it "returns nil url if avatar_kind is nil" do
      user.avatar_kind = nil
      user.avatar_url.should == nil
    end
    it "returns large sized image if large parameter is supplied" do
      user.stub(:gravatar_url).with(:size => User::LARGE_PIXEL_CONST).
        and_return("/app/assets/images/large-gravatar.jpg")
      user.avatar_kind = "gravatar"
      user.avatar_url("large").should == "/app/assets/images/large-gravatar.jpg"
    end
    it "returns medium sized image if medium parameter is supplied"
    it "returns small sized image if small parameter is thumb"
  end

  it "sets deleted_at (Time.current) when deactivate! is called" do
    user.deactivate!
    user.deleted_at.should be_true
  end

  it "unsets deleted_at (nil) when activate! is called" do
    user.update_attribute(:deleted_at, 1.month.ago)
    user.activate!
    user.deleted_at.should be_nil
  end

  describe "active_for_authentication?" do
    it "returns false if deleted_at is present" do
      user.update_attribute(:deleted_at, 1.month.ago)
      user.should_not be_active_for_authentication
    end

    it "returns true if deleted_at is nil" do
      user.update_attribute(:deleted_at, nil)
      user.should be_active_for_authentication
    end
  end
end
