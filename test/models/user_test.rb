require 'test_helper'

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(
      name: "Test User #{SecureRandom.hex(4)}",
      email: "user_#{SecureRandom.hex(4)}@test.com",
      password: "a_good_password",
      password_confirmation: "a_good_password"
    )
    @group = Group.create!(name: "User Group #{SecureRandom.hex(4)}", group_privacy: 'secret')
  end

  # Password validations
  test "accepts a good password with confirmation" do
    user = User.new(
      name: "New User",
      email: "newuser_#{SecureRandom.hex(4)}@test.com",
      password: "a_good_password",
      password_confirmation: "a_good_password"
    )
    assert user.valid?
  end

  test "fails if password confirmation does not match" do
    user = User.new(
      name: "New User",
      email: "newuser_#{SecureRandom.hex(4)}@test.com",
      password: "a_good_password",
      password_confirmation: "not_the_same"
    )
    assert_not user.valid?
  end

  test "requires password to be at least 8 characters long" do
    user = User.new(
      name: "New User",
      email: "newuser_#{SecureRandom.hex(4)}@test.com",
      password: "PSWD",
      password_confirmation: "PSWD"
    )
    assert_not user.valid?
  end

  test "only requires password to be valid when being updated" do
    @user.password = 'qwerty123'
    @user.save!(validate: false)
    reloaded = User.find(@user.id)
    reloaded.save!
    assert_equal 0, reloaded.errors[:password].size
  end

  test "accepts any valid password" do
    @user.password = 'hey_this_is_fairly_complex'
    @user.password_confirmation = 'hey_this_is_fairly_complex'
    assert @user.save!
  end

  # Username validations
  test "requires username contain no whitespace" do
    @user.username = 'user name'
    @user.valid?
    assert @user.errors[:username].any?
  end

  test "requires username not have special characters" do
    %w[username? username/ user_name user-name].each do |bad_username|
      @user.username = bad_username
      @user.valid?
      assert @user.errors[:username].any?, "Expected errors for username '#{bad_username}'"
    end
  end

  test "requires username is lower case" do
    @user.username = 'USERNAME'
    @user.valid?
    assert @user.errors[:username].any?
  end

  # Gravatar/avatar
  test "sets avatar_kind to initials by default in test env" do
    user = User.new(
      name: "Gravatar User",
      email: "gravatar_#{SecureRandom.hex(4)}@test.com",
      password: "a_good_password"
    )
    # has_gravatar? returns false in test env, so avatar_kind defaults to initials
    user.save!
    assert_equal "initials", user.avatar_kind
  end

  test "email can have an apostrophe" do
    user = User.new(email: "mr.d'arcy@gumby.com")
    user.valid?
    assert_equal 0, user.errors[:email].size
  end

  # Associations
  test "has many groups" do
    @group.add_member!(@user)
    assert_includes @user.groups, @group
  end

  test "has many adminable_groups" do
    @group.add_admin!(@user)
    assert_includes @user.adminable_groups, @group
  end

  test "has many admin memberships" do
    membership = @group.add_admin!(@user)
    assert_includes @user.admin_memberships, membership
  end

  test "has authored discussions" do
    @group.add_member!(@user)
    discussion = Discussion.new(group: @group, title: "Hello world", private: true)
    discussion.author = @user
    discussion.save!
    assert_includes @user.authored_discussions, discussion
  end

  # Experiences
  test "can store user experiences" do
    @user.experienced!(:happiness)
    assert_equal true, @user.experiences['happiness']
  end

  test "does not store other experiences" do
    @user.experienced!(:frustration)
    assert_nil @user.experiences['happiness']
  end

  test "can forget experiences" do
    @user.update!(experiences: { happiness: true })
    @user.experienced!(:happiness, false)
    assert_equal false, @user.experiences['happiness']
  end

  # Secret token
  test "ensures new users have secret_token" do
    User.import [User.new(name: "User", email: "secrettoken_#{SecureRandom.hex(4)}@example.com", password: "sssYZ123")]
    imported = User.find_by(name: "User")
    assert imported.secret_token.present?
  end

  test "generates a token for a new user" do
    u = User.create!(name: "Token User", email: "tokenuser_#{SecureRandom.hex(4)}@example.com", password: "passwordXYZ123")
    assert u.secret_token.present?
  end

  # Usernames
  test "generates a unique username" do
    user1 = User.new(name: "Test User", email: "testuser1_#{SecureRandom.hex(4)}@example.com", password: "passwordXYZ123")
    user1.generate_username
    user1.save!
    user2 = User.new(name: "Test User", email: "testuser2_#{SecureRandom.hex(4)}@example.com", password: "passwordXYZ123")
    user2.generate_username
    user2.save!
    assert_not_equal user1.username, user2.username
  end

  test "does not change username if already correctly set" do
    user1 = User.new(name: "Test User", email: "testuser1_#{SecureRandom.hex(4)}@example.com", password: "passwordXYZ123")
    user1.generate_username
    user1.save!
    user2 = User.new(name: "Test User", email: "testuser2_#{SecureRandom.hex(4)}@example.com", password: "passwordXYZ123")
    user2.username = "testuser1#{SecureRandom.hex(2)}"
    user2.save!
    original_username = user2.username
    user2.generate_username
    assert_equal original_username, user2.username
  end

  test "ensures usernames are stripped from email addr names" do
    user = User.new(name: "james@example.com", email: "james_#{SecureRandom.hex(4)}@example.com", password: "passwordXYZ123")
    user.generate_username
    assert_not_equal "james@example.com", user.username
  end

  test "does not allow non-alphanumeric characters in usernames" do
    user = User.new(name: "R!chard D. Bar_tle*tt$", email: "richard_#{SecureRandom.hex(4)}@example.com")
    user.generate_username
    assert_equal "rcharddbartlett", user.username
  end

  test "changes non ASCII characters to their ASCII counterparts" do
    user = User.new(name: "Kæsper Nørdskov _^25*/\\!", email: "kaesper_#{SecureRandom.hex(4)}@example.com")
    user.generate_username
    assert_equal "kaespernordskov25", user.username
  end

  test "usernames radical should be 18 characters max" do
    user = User.new(name: "Wow this is quite long as a name", email: "longname_#{SecureRandom.hex(4)}@example.com")
    user.generate_username
    assert_equal 18, user.username.length
  end
end
