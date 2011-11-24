require 'spec_helper'

describe Membership do
  before :each do
    @membership = Membership.new
    @membership.valid?
  end
  it "must have a group" do
    @membership.should have(1).errors_on(:group)
  end
  it "must have a user" do
    @membership.should have(1).errors_on(:user)
  end
  it "should have access_level of request" do
    @membership.access_level.should == 'request'
  end

  it "cannot have duplicate memberships" do
    @user = User.make!
    @group = Group.make!
    m = Membership.make(:user => @user, :group => @group)
    m.save
    m.should be_valid
    m1 = Membership.make(:user => @user, :group => @group)
    m1.should_not be_valid
  end
end
