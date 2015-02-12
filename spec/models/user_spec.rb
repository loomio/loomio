require 'rails_helper'

describe User do
  before(:all) {
    BlacklistedPassword.create(string: 'qwerty12')
    BlacklistedPassword.create(string: 'qwerty123')
  }

  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:restrictive_group) { create(:group, members_can_start_discussions: false) }
  let(:admin) { create :user }

  subject do
    user = User.new
    user.valid?
    user
  end

  it "cannot have invalid avatar_kinds" do
    user.avatar_kind = 'bad'
    user.should have(1).errors_on(:avatar_kind)
  end

  it "should require the password to be at least 8 characters long" do
    user.password = 'PSWD'
    user.should have(1).errors_on(:password)
  end

  it "should only require the password to be valid when it's being updated" do
    user.password = 'qwerty123'
    user.save!(:validate => false)
    user_id = user.id
    user = User.find_by_id(user_id)
    user.save!
    user.should have(0).errors_on(:password)
  end

  it "should require the password to be non-trivial" do
    user.password = 'qwerty123'
    user.should have(1).errors_on(:password)
  end

  it "should require the password to be non-trivial regardless of the case" do
    user.password = 'QwerTy12'
    user.should have(1).errors_on(:password)
  end

  it "should otherwise accept any password" do
    user.password = 'hey_this_is_fairly_complex'
    user.save!
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

  it "has many groups that discussions can be started in" do
    group.add_member!(user)
    restrictive_group.add_member!(user)
    restrictive_group.add_admin!(admin)

    user.groups_discussions_can_be_started_in.should include(group)
    user.groups_discussions_can_be_started_in.should_not include(restrictive_group)
    admin.groups_discussions_can_be_started_in.should include(restrictive_group)
  end

  it "has many admin memberships" do
    membership = group.add_admin!(user)
    user.admin_memberships.should include(membership)
  end

  it "has authored discussions" do
    group.add_member!(user)
    discussion = Discussion.new(:group => group, :title => "Hello world", private: true)
    discussion.author = user
    discussion.save!
    user.authored_discussions.should include(discussion)
  end

  it "has authored motions" do
    group.add_member!(user)
    discussion = create :discussion, group: group
    motion = FactoryGirl.create(:motion, discussion: discussion, author: user)
    user.authored_motions.should include(motion)
  end

  describe "#voting_motions" do
    it "returns motions that belong to user and are open" do
      discussion = create :discussion, group: group
      motion = FactoryGirl.create(:motion, author: user, discussion: discussion)
      user.voting_motions.should include(motion)
    end

    it "should not return motions that belong to the group but are closed'" do
      discussion = create :discussion, group: group
      motion = FactoryGirl.create(:motion, author: user, discussion: discussion)
      MotionService.close(motion)

      user.voting_motions.should_not include(motion)
    end
  end

  describe "closed_motions" do
    it "returns motions that belong to the group and are closed" do
      discussion = create :discussion, group: group
      motion = FactoryGirl.create(:motion, author: user, discussion: discussion)
      MotionService.close(motion)
      user.closed_motions.should include(motion)
    end

    it "should not return motions that belong to the group but are closed" do
      discussion = create :discussion, group: group
      motion = FactoryGirl.create(:motion, author: user, discussion: discussion)
      user.closed_motions.should_not include(motion)
    end
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
    it "returns '[deactivated account]' if deactivated_at is true (a date is present)" do
      user.update_attribute(:deactivated_at, Time.now)
      user.name.should include('deactivated account')
    end

    it "returns the stored name if deactivated_at is nil" do
      user.name.should_not == 'Deleted user'
    end
  end

  it "sets avatar initials on save" do
    user.should_receive(:set_avatar_initials)
    user.save
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

  describe "deactivation" do

     before do
       @membership = group.add_member!(user)
       user.deactivate!
     end

     describe "#deactivate!" do

       it "sets deactivated_at to (Time.now)" do
         user.deactivated_at.should be_present
       end

       it "archives the user's memberships" do
         user.archived_memberships.should include(@membership)
       end
     end

     describe "#reactivate!" do

       before do
         user.reactivate!
       end

       it "unsets deactivated_at (nil)" do
         user.deactivated_at.should be_nil
       end

       it "restores the user's memberships" do
         user.memberships.should include(@membership)
       end
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

  describe "usernames" do
    before do
      @user1 = User.new(name: "Test User", email: "test1@example.com", password: "passwordXYZ123")
      @user2 = User.new(name: "Test User", email: "test2@example.com", password: "passwordXYZ123")
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
      other_user = FactoryGirl.create :user
      group.add_member!(other_user)
      user.in_same_group_as?(other_user).should == true
    end
    it "returns false if user and other_user do not share any groups" do
      group.add_member!(user)
      other_user = FactoryGirl.create :user
      user.in_same_group_as?(other_user).should == false
    end
  end

  describe "belongs_to_manual_subscription_group?" do
    it "returns true if user is a member of a manual subscription group" do
      group.update_attribute :payment_plan, 'manual_subscription'
      group.add_member! user
      user.belongs_to_manual_subscription_group?.should be true
    end

    it "returns false if user is a member of a subscription group" do
      group.update_attribute :payment_plan, 'subscription'
      group.add_member! user
      user.belongs_to_manual_subscription_group?.should be false
    end

    it "returns false if user is a member of a paying group" do
      group.update_attribute :payment_plan, 'pwyc'
      user.belongs_to_manual_subscription_group?.should be false
    end
  end
end
