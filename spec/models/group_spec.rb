require 'spec_helper'

describe Group do
  context "a new group" do
    before :each do
      @group = Group.new
      @group.valid?
      @group
    end
    it "must have a name" do
      @group.should have(1).errors_on(:name)
    end
    it "has memberships" do
      @group.respond_to?(:memberships)
    end
  end
  context "an existing group" do
    before :each do
      @group = Group.make!
      @user = User.make!
    end
    it "can add a member" do
      @group.add_member!(@user)
      @group.users.should include(@user)
    end
    context "member request" do
      before :each do
        @group.add_request!(@user)
      end
      it "should not add user to group" do
        @group.users.should_not include(@user)
      end
      it "should add user to group member requests" do
        @group.membership_requests.find_by_user_id(@user).should exist
      end
    end
    # context "a requested member" do
    #   before :each do
    #     @group.add_request!(@user)
    #   end
    #   it "should not be in group users" do
    #     @group.users.should_not include(@user)
    #   end
    # end
  end
end
