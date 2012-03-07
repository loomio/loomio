require 'spec_helper'

describe Membership do
  describe "validation" do
    let(:membership) { Membership.new }

    it "must have a group" do
      membership.valid?
      membership.should have(1).errors_on(:group)
    end

    it "must have a user" do
      membership.valid?
      membership.should have(1).errors_on(:user)
    end

    it "should have access_level of request" do
      membership.valid?
      membership.access_level.should == 'request'
    end

    it "cannot have duplicate memberships" do
      @user = User.make!
      @group = Group.make!
      Membership.make!(:user => @user, :group => @group)

      membership.user == @user
      membership.group == @group
      membership.should_not be_valid
    end
  end
end
