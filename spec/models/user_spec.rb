require 'spec_helper'

describe User do
  let(:user) { User.make! }
  let(:group) { Group.make! }

  subject do
    user = User.new
    user.valid?
    user
  end

  it { should have_many(:notifications) }
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
    group.add_member!(user)
    user.groups.should include(group)
  end

  it "has many adminable_groups" do
    group.add_admin!(user)
    user.adminable_groups.should include(group)
  end

  it "has many admin memberships" do
    membership = group.add_admin!(user)
    user.admin_memberships.should include(membership)
  end

  it "has correct group request" do
    Membership.make!(:group => group, :user => user)
    user.group_requests.should include(group)
  end

  describe "open_votes" do
    before do
      @motion = create_motion
      @motion.group.add_member! user
      @vote = user.votes.new(:position => "yes")
      @vote.motion = @motion
      @vote.save
    end

    it "returns the user's votes on motions that are open" do
      user.open_votes.should include(@vote)
    end

    it "does not return the user's votes on motions that are closed" do
      @motion.close_voting!
      user.open_votes.should_not include(@vote)
    end
  end

  it "has authored discussions" do
    group.add_member!(user)
    discussion = Discussion.new(:group => group, :title => "Hello world")
    discussion.author = user
    discussion.save!
    user.authored_discussions.should include(discussion)
  end

  it "has authored motions" do
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

  describe "inviting user to Loomio and to group" do
    before do
      @inviter = User.make!
      @group = Group.make!
      @user = User.invite_and_notify!({email: "foo@example.com"}, @inviter, @group)
    end

    it "adds user to group" do
      @group.users.should include(@user)
    end

    it "adds inviter to membership" do
      @user.memberships.first.inviter.should == @inviter
    end
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

  describe "mark_notifications_as_viewed" do
    before do
      @notif1 = Notification.create!(:event => mock_model(Event), :user => user)
      @notif2 = Notification.create!(:event => mock_model(Event), :user => user)
      @notif3 = Notification.create!(:event => mock_model(Event), :user => user)
      user.mark_notifications_as_viewed! @notif2.id
    end

    it "marks all notifications before given notification id as viewed" do
      user.unviewed_notifications.count.should == 1
      @notif1.reload
      @notif1.viewed_at.should_not be_nil
    end

    it "does not mark notifications after given notification id as viewed" do
      @notif3.reload
      @notif3.viewed_at.should be_nil
    end
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

  it "sets the avatar initials after it saves" do
    user.should_receive(:set_avatar_initials)
    user.save!
  end

  describe "#set_avatar_initials" do
    it "sets avatar_initials to 'DU' if deleted_at is true (a date is present)" do
      user.deleted_at = "20/12/2002"
      user.set_avatar_initials
      user.avatar_initials.should == "DU"
    end
    it "sets avatar_initials to the first two characters in all caps of the email if the user's name is email" do
      user.name = "bobbysin@tvhosts.com"
      user.email = "bobbysin@tvhosts.com"
      user.set_avatar_initials
      user.avatar_initials.should == "BO"
    end
    it "returns the first three initials of the stored name" do
      user.name = "Bob bobby sinclair deebop"
      user.set_avatar_initials
      user.avatar_initials.should == "BBS"
    end
    it "works for strange characters" do
      user.name = "D'Angelo (Loco)"
      user.set_avatar_initials
      user.avatar_initials.should == "D("
    end
  end

  describe "avatar_url" do
    it "returns gravatar url if avatar_kind is 'gravatar'" do
      user.should_receive(:gravatar_url).and_return('www.gravatar/spike')
      user.avatar_kind = 'gravatar'
      user.avatar_url.should == 'www.gravatar/spike'
    end

    context "where avatar_kind is 'uploaded'" do
      before do
        @uploaded_avatar = double "paperclip_image"
        user.should_receive(:uploaded_avatar).and_return(@uploaded_avatar)
      end
      it "returns medium url if no size is specified" do
        @uploaded_avatar.should_receive(:url).with(:medium).and_return('www.gravatar/uploaded/mike')
        user.avatar_kind = 'uploaded'
        user.avatar_url.should == 'www.gravatar/uploaded/mike'
      end
      it "returns large url if large size is specified" do
        @uploaded_avatar.should_receive(:url).with(:large).and_return('www.gravatar/uploaded/mike')
        user.avatar_kind = 'uploaded'
        user.avatar_url(:large).should == 'www.gravatar/uploaded/mike'
      end
      it "returns medium url if medium size is specified" do
        @uploaded_avatar.should_receive(:url).with(:medium).and_return('www.gravatar/uploaded/mike')
        user.avatar_kind = 'uploaded'
        user.avatar_url(:medium).should == 'www.gravatar/uploaded/mike'
      end
      it "returns small url if small size is specified" do
        @uploaded_avatar.should_receive(:url).with(:small).and_return('www.gravatar/uploaded/mike')
        user.avatar_kind = 'uploaded'
        user.avatar_url(:small).should == 'www.gravatar/uploaded/mike'
      end
    end

    it "returns nil url if avatar_kind is nil" do
      user.avatar_kind = nil
      user.avatar_url.should == nil
    end
  end

  describe "gravatar?(email, options = {})" do
    it "should return true if gravatar exists"
    it "should return false if gravater does not exist"
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

  describe "unviewed_notifications" do
    it "returns notifications that the user has not viewed yet" do
      notification = Notification.create!(:event => mock_model(Event),
                                          :user => user)
      user.unviewed_notifications.first.id.should == notification.id
    end
    it "does not return notifications that the user has viewed" do
      notification = Notification.new(:event => mock_model(Event),
                                      :user => user)
      notification.viewed_at = Time.now
      notification.save
      user.unviewed_notifications.count.should == 0
    end
  end

  describe "recent_notifications" do
    it "returns 10 notifications if there are less than 10 _unread_ notifications" do
      (0..15).each do |i|
        notification = Notification.new(:event => stub_model(Event),
                                        :user => user)
        notification.viewed_at = Time.now
        notification.save!
      end
      user.recent_notifications.count.should == 10
    end
    it "returns 20 notifications if there are 20 or more _unread_ notifications" do
      (0..25).each do |i|
        Notification.create!(:event => stub_model(Event), :user => user)
      end
      user.recent_notifications.count.should == 20
    end
  end
end
