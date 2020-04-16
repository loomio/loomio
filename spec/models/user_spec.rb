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
  let(:new_user) { build(:user, password: "a_good_password", password_confirmation: "a_good_password") }

  it "should accept a good password with a confirmation" do
    expect(new_user.valid?).to eq true
  end

  it "should fail if password confirmation does not match" do
    new_user.password_confirmation = 'not_the_same'
    expect(new_user.valid?).to eq false
  end

  it "should require the password to be at least 8 characters long" do
    new_user.password = 'PSWD'
    new_user.password_confirmation = 'PSWD'
    expect(new_user.valid?).to eq false
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

  it "email can be duplicated for non-email verified accounts" do
    create(:user, email: 'example@example.com', email_verified: false)
    user = build(:user, email: 'example@example.com', email_verified: false)
    expect(user).to be_valid
    user.email_verified = true
    expect(user).to be_valid
  end

  it "email cannot be duplicated for email verified accounts" do
    create(:user, email: 'example@example.com', email_verified: true)
    user = build(:user, email: 'example@example.com', email_verified: false)
    expect(user).to be_valid
    user.email_verified = true
    expect(user).to_not be_valid
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

  it "has authored discussions" do
    group.add_member!(user)
    discussion = Discussion.new(:group => group, :title => "Hello world", private: true)
    discussion.author = user
    discussion.save!
    user.authored_discussions.should include(discussion)
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

  describe "experienced" do

    it "can store user experiences" do
      user.experienced!(:happiness)
      expect(user.experiences['happiness']).to eq true
    end

    it "does not store other experiences" do
      user.experienced!(:frustration)
      expect(user.experiences['happiness']).to eq nil
    end

    it "can forget experiences" do
      user.update(experiences: { happiness: true })
      user.experienced!(:happiness, false)
      expect(user.experiences['happiness']).to eq false
    end
  end

  describe "deactivation" do

    before do
      @membership = group.add_member!(user)
    end

    describe "#deactivate!" do

      it "sets deactivated_at to (Time.now)" do
        user.deactivate!
        user.deactivated_at.should be_present
      end

      it "archives the user's memberships" do
        user.deactivate!
        user.archived_memberships.should include(@membership)
      end

      it "should update group.memberships_count" do
        expect{user.deactivate!}.to change{group.reload.memberships_count}.by(-1)
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

  describe 'find_by_email' do
    it 'is case insensitive' do
      user = create(:user, email: "bob@bob.com")
      expect(User.find_by(email: "BOB@bob.com")).to eq user
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
end
