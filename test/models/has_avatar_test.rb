require 'test_helper'
require_relative '../../app/models/concerns/avatar_initials'

class DummyUser
  include AvatarInitials
  attr_accessor :name, :email, :deactivated_at, :avatar_initials
end

class HasAvatarTest < ActiveSupport::TestCase
  setup do
    @user = DummyUser.new
    @user.name = "Rob Gob"
    @user.email = "rob@gob.com"
  end

  test "sets avatar_initials to DU if deactivated" do
    @user.deactivated_at = "20/12/2002"
    @user.set_avatar_initials
    assert_equal "DU", @user.avatar_initials
  end

  test "sets avatar_initials to first initials of name" do
    @user.set_avatar_initials
    assert_equal "RG", @user.avatar_initials
  end

  test "returns the first three initials of a long name" do
    @user.name = "Bob bobby sinclair deebop"
    @user.set_avatar_initials
    assert_equal "BBS", @user.avatar_initials
  end

  test "returns first two characters of email if no name" do
    @user.name = nil
    @user.set_avatar_initials
    assert_equal "RO", @user.avatar_initials
  end
end
