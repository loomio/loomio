# encoding: UTF-8
require 'spec_helper'

describe User do
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  subject do
    user = User.new
    user.valid?
    user
  end

  it { should have_many(:notifications) }
  it { should have(1).errors_on(:name) }
  it { should respond_to(:uses_markdown) }

  it "must have a valid email" do
    user = User.new
    user.email = '"Joe Gumby" <joe@gumby.com>'
    user.valid?
    user.should have(1).errors_on(:email)
  end

  it "has uploaded avatar less than 1000kb "

  it "cannot have invalid avatar_kinds" do
    user.avatar_kind = 'bad'
    user.should have(1).errors_on(:avatar_kind)
  end

  it "sets the avatar_kind to gravatar if user has one" do
    user = User.new attributes_for(:user)
    user.stub(:has_gravatar? => true)
    user.save!
    user.avatar_kind.should == "gravatar"
  end

  it "does not set avatar_kind if user does not have gravatar" do
    user = User.new attributes_for(:user)
    user.stub(:has_gravatar?).and_return(false)
    user.save!
    user.avatar_kind.should == 'initials'
  end

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
    create(:membership,:group => group, :user => user)
    user.group_requests.should include(group)
  end

  describe "open_votes" do
    before do
      @motion = create(:motion)
      @motion.group.add_member! user
      @vote = user.votes.new(:position => "yes")
      @vote.motion = @motion
      @vote.save
    end

    it "returns the user's votes on motions that are open" do
      user.open_votes.should include(@vote)
    end

    it "does not return the user's votes on motions that are closed" do
      @motion.close!
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
    discussion = create :discussion, group: group
    motion = create(:motion, discussion: discussion, author: user)
    user.authored_motions.should include(motion)
  end

  describe "motions_in_voting_phase" do
    it "returns motions that belong to user and are in phase 'voting'" do
      motion = create(:motion, author: user)
      user.motions_in_voting_phase.should include(motion)
    end

    it "should not return motions that belong to the group but are in phase 'closed'" do
      motion = create(:motion, author: user)
      motion.close!
      user.motions_in_voting_phase.should_not include(motion)
    end
  end

  describe "motions_closed" do
    it "returns motions that belong to the group and are in phase 'voting'" do
      motion = create(:motion, author: user)
      motion.close!
      user.motions_closed.should include(motion)
    end

    it "should not return motions that belong to the group but are in phase 'closed'" do
      motion = create(:motion, author: user)
      user.motions_closed.should_not include(motion)
    end
  end

  context do
    before do
      group.add_member! user
      @discussion1 = create :discussion, :group => group
      motion1 = create :motion, discussion: @discussion1, author: user
      @discussion2 = create :discussion, :group => group
      motion2 = create :motion, discussion: @discussion2, author: user
      vote = Vote.new position: "yes"
      vote.motion = motion2
      vote.user = user
      vote.save
    end
    describe "discussions_with_current_motion_not_voted_on" do
      it "returns all discussions with a current motion that a user has not voted on" do
        user.discussions_with_current_motion_not_voted_on.should include(@discussion1)
        user.discussions_with_current_motion_not_voted_on.should_not include(@discussion2)
      end
    end

    describe "discussions_with_current_motion_voted_on" do
      it "returns all discussions with a current motion that a user has voted on" do
        user.discussions_with_current_motion_voted_on.should include(@discussion2)
        user.discussions_with_current_motion_voted_on.should_not include(@discussion1)
      end
    end
  end

  describe "user.discussions_sorted" do
    before do
      @user = create :user
      @group = create :group
      @group.add_member! @user
      @discussion1 = create :discussion, group: @group, :author => @user
    end

    it "returns a list of discussions sorted by last_comment_at" do
      pending 'this does not help'
      @discussion2 = create :discussion, :author => @user
      @discussion2.add_comment @user, "hi", false
      @discussion3 = create :discussion, :author => @user
      @discussion1.add_comment @user, "hi", false
      @user.discussions_sorted.should == [@discussion1, @discussion4, @discussion3, ]
      @user.discussions_sorted[0].should == @discussion1
      @user.discussions_sorted[1].should == @discussion4
      @user.discussions_sorted[2].should == @discussion3
      @user.discussions_sorted[3].should == @discussion2
    end

    it "should not include discussions with a current motion" do
      motion = create :motion, :discussion => @discussion1, author: @user
      motion.close!
      motion1 = create :motion, :discussion => @discussion1, author: @user
      @user.discussions_sorted.should_not include(@discussion1)
    end
  end

  describe "user.voted?(motion)" do
    before do
      group.add_member!(user)
      discussion = create :discussion, group: group
      @motion = create :motion, discussion: discussion, author: user
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

  it "can find user by email (case-insensitive)" do
    user = create(:user, email: "foobar@example.com")
    User.find_by_email("foObAr@exaMPLE.coM").should == user
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

  context "#create" do
    it "sets the avatar initials" do
      user.should_receive(:set_avatar_initials)
      user.save!
    end
  end

  context "#save" do
    it "sets avatar_initials to 'DU' if deleted_at is true (a date is present)" do
      user.deleted_at = "20/12/2002"
      user.save!
      user.avatar_initials.should == "DU"
    end
    it "sets avatar_initials to the first two characters in all caps of the email if the user's name is email" do
      user.name = "bobbysin@tvhosts.com"
      user.email = "bobbysin@tvhosts.com"
      user.save!
      user.avatar_initials.should == "BO"
    end
    it "returns the first three initials of the stored name" do
      user.name = "Bob bobby sinclair deebop"
      user.save!
      user.avatar_initials.should == "BBS"
    end
    it "works for strange characters" do
      user.name = "D'Angelo (Loco)"
      user.save!
      user.avatar_initials.should == "D("
    end
  end

  describe "#using_initials?" do
    it "returns true if user avatar_kind is 'initials'" do
      user.avatar_kind = "initials"
      user.using_initials?.should == true
    end
    it "returns false if user avatar_kind is something else" do
      user.avatar_kind = "uploaded"
      user.using_initials?.should == false
    end
  end

  describe "#has_uploaded_image?" do
    it "returns true if user has uploaded an image" do
      user.stub_chain(:uploaded_avatar, :url).and_return('/uploaded_avatars/medium/pants.png')
      user.has_uploaded_image?.should == true
    end
    it "returns false if user has not uploaded an image" do
      user.has_uploaded_image?.should == false
    end
  end

  describe "gravatar?(options = {})" do
    it "returns true if gravatar exists"
    it "returns false if gravater does not exist"
  end

  describe "avatar_url" do
    it "returns gravatar url if avatar_kind is 'gravatar'" do
      user.should_receive(:gravatar_url).and_return('www.gravatar/spike')
      user.avatar_kind = 'gravatar'
      user.avatar_url(:small).should == 'www.gravatar/spike'
    end

    context "where avatar_kind is 'uploaded'" do
      before do
        @uploaded_avatar = double "paperclip_image"
        user.should_receive(:uploaded_avatar).and_return(@uploaded_avatar)
      end
      it "returns medium url if no size is specified" do
        @uploaded_avatar.should_receive(:url).with(:medium).and_return('www.gravatar/uploaded/mike')
        user.avatar_kind = 'uploaded'
        user.avatar_url(:medium).should == 'www.gravatar/uploaded/mike'
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

  describe "get_loomio_user" do
    it "returns the loomio helper bot user (email: contact@loom.io)" do
      user = User.new
      user.name = "loomio evil bot"
      user.email = "darkness@loom.io"
      user.password = "password"
      user.save!
      user1 = User.find_or_create_by_email("contact@loom.io")
      user1.name = "loomio helper bot"
      user1.password = "password"
      user1.save!
      user2 = User.new
      user2.name = "George Washingtonne"
      user2.email = "georgie_porgie@usa.com"
      user2.password = "password"
      user2.save!
      User.loomio_helper_bot.should == user1
    end

    it "creates loomio helper bot if none exists" do
      User.loomio_helper_bot.email.should == "contact@loom.io"
    end
  end

  describe "recent_notifications" do
    it "returns 10 notifications if there are less than 10 _unread_ notifications" do
      # Generate read notifications
      (0..15).each do |i|
        notification = Notification.new(:event => stub_model(Event),
                                        :user => user)
        notification.viewed_at = Time.now
        notification.save!
      end
      # Generate unread notifications
      (0..7).each do |i|
        notification = Notification.new(:event => stub_model(Event),
                                        :user => user)
        notification.save!
      end
      user.recent_notifications.count.should == 10
    end
    it "returns 25 notifications if there are 25 or more _unread_ notifications" do
      (0..30).each do |i|
        Notification.create!(:event => stub_model(Event), :user => user)
      end
      user.recent_notifications.count.should == 25
    end
  end

  describe "usernames" do
    before do
      @user1 = User.new(name: "Test User", email: "test1@example.com", password: "password")
      @user2 = User.new(name: "Test User", email: "test2@example.com", password: "password")
    end
    it "generates a unique username" do
      @user1.generate_username
      @user1.save!
      @user2.generate_username
      @user2.save!
      @user1.username.should_not == @user2.username
    end

    it "doesn't change username if already correctly set" do
      @user1.generate_username # @user1.username now equals "testuser"
      @user1.save!
      @user2.username = "testuser1"
      @user2.save!
      expect{ @user2.generate_username }.to_not change{@user2.username}
    end

    it "ensures usernames are stripped from email addr names" do
      user = User.new
      user.name = "james@example.com"
      user.email = "james@example.com"
      user.password = "password"
      user.generate_username
      user.username.should_not == "james@example.com"
    end

    it "does not allow non-alphanumeric characters in usernames" do
      user = User.new
      user.name = "R!chard D. Bar_tle*tt$"
      user.generate_username
      user.username.should == "rcharddbartlett"
    end

    it "changes non ASCII characters to their ASCII counterparts" do
      user = User.new
      user.name = "Kæsper Nørdskov _^25*/\!"
      user.generate_username
      user.username.should == "kaespernordskov25"
    end

    it "usernames radical should be 18 characters max" do
      user = User.new
      user.name = "Wow this is quite long as a name"
      user.generate_username
      user.username.length.should equal(18)
    end
  end

  describe "#in_same_group_as?(other_user)" do
    it "returns true if user and other_user are in the same group" do
      group.add_member!(user)
      other_user = create :user
      group.add_member!(other_user)
      user.in_same_group_as?(other_user).should == true
    end
    it "returns false if user and other_user do not share any groups" do
      group.add_member!(user)
      other_user = create :user
      user.in_same_group_as?(other_user).should == false
    end
  end

  describe "belongs_to_paying_group" do
    it "returns true if user is a member of a paying group" do
      group.paying_subscription = true
      group.save!
      group.add_member!(user)
      user.belongs_to_paying_group?.should == true
    end
    it "returns false if user is not a member of a paying group" do
      group.paying_subscription == false
    end
  end

end
