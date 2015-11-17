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

  it "should require the username contain no whitespace" do
    user.username = 'user name'
    user.should have(1).errors_on(:username)
  end

  it "should require the username not have special characters" do
    user.username = 'username?'
    user.should have(1).errors_on(:username)
    user.username = 'username/'
    user.should have(1).errors_on(:username)
    user.username = 'user_name'
    user.should have(1).errors_on(:username)
    user.username = 'user-name'
    user.should have(1).errors_on(:username)
  end

  it 'should require the username is lower case' do
    user.username = 'USERNAME'
    user.should have(1).errors_on(:username)
  end

  it "sets the avatar_kind to gravatar if user has one" do
    user = User.new attributes_for(:user)
    user.stub(:has_gravatar? => true)
    user.save!
    expect(user.avatar_kind).to eq "gravatar"
  end

  it "does not set avatar_kind if user does not have gravatar" do
    user = User.new attributes_for(:user)
    user.stub(:has_gravatar?).and_return(false)
    user.save!
    expect(user.avatar_kind).to eq 'initials'
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
      expect(user.using_initials?).to be true
    end
    it "returns false if user avatar_kind is something else" do
      user.avatar_kind = "uploaded"
      expect(user.using_initials?).to be false
    end
  end

  describe "#has_uploaded_image?" do
    it "returns true if user has uploaded an image" do
      user.stub_chain(:uploaded_avatar, :url).and_return('/uploaded_avatars/medium/pants.png')
      expect(user.has_uploaded_image?).to be true
    end
    it "returns false if user has not uploaded an image" do
      expect(user.has_uploaded_image?).to be false
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
      expect(user.username).to eq "rcharddbartlett"
    end

    it "changes non ASCII characters to their ASCII counterparts" do
      user = User.new
      user.name = "Kæsper Nørdskov _^25*/\!"
      user.generate_username
      expect(user.username).to eq "kaespernordskov25"
    end

    it "usernames radical should be 18 characters max" do
      user = User.new
      user.name = "Wow this is quite long as a name"
      user.generate_username
      expect(user.username.length).to eq 18
    end
  end

  describe "#in_same_group_as?(other_user)" do
    it "returns true if user and other_user are in the same group" do
      group.add_member!(user)
      other_user = FactoryGirl.create :user
      group.add_member!(other_user)
      expect(user.in_same_group_as?(other_user)).to be true
    end
    it "returns false if user and other_user do not share any groups" do
      group.add_member!(user)
      other_user = FactoryGirl.create :user
      expect(user.in_same_group_as?(other_user)).to be false
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
