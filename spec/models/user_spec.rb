require 'spec_helper'

describe User do
  subject do
    @user = User.new
    @user.valid?
    @user
  end
  it {should have(1).errors_on(:name)}

  it "must have a valid email" do
    @user = User.new
    @user.email = '"Joe Gumby" <joe@gumby.com>'
    @user.valid?
    @user.should have(1).errors_on(:email)
  end

  it "has many groups" do
    @user = User.make!
    @group = Group.make!
    @group.add_member!(@user)
    @user.groups.should include(@group)
  end

  it "has correct group request" do
    @user = User.make!
    @group = Group.make!
    Membership.make!(:group => @group, :user => @user)
    @user.group_requests.should include(@group)
  end

  it "can be invited" do
    @inviter = User.make!
    @group = Group.make!
    @user = User.invite_and_notify!({email: "foo@example.com"}, @inviter, @group)
    @group.users.should include(@user)
  end

  it "invited user should have email as name" do
    @user = User.invite_and_notify!({email: "foo@example.com"}, User.make!, Group.make!)
    @user.name.should == @user.email
  end

  it "can find user by email (case-insensitive)" do
    @user = User.make!(email: "foobar@example.com")
    User.find_by_email("foObAr@exaMPLE.coM").should == @user
  end

  it "can create a new motion_read_log" do
    @user = User.make!
    @group = Group.make!
    @discussion = create_discussion(group: @group)
    @user.update_discussion_read_log(@discussion)
    DiscussionReadLog.count.should == 1
  end

  it "can update an existing motion_read_log" do
    @user = User.make!
    @group = Group.make!
    @discussion = create_discussion(group: @group)
    @discussion.activity = 4
    @user.update_discussion_read_log(@discussion)
    @discussion.activity = 5
    @user.discussion_activity_when_last_read(@discussion).should == 4
    @user.update_discussion_read_log(@discussion)
    @user.discussion_activity_when_last_read(@discussion).should == 5
  end
  
  describe "name" do
    it "returns 'Deleted User' if deleted_at is true (a date is present)" do
      @user = User.make!
      @user.update_attribute(:deleted_at, 1.month.ago)
      @user.name.should == 'Deleted user'
    end
  
    it "returns the stored name if deleted_at is nil" do
      @user = User.make!
      @user.name.should_not == 'Deleted user'
    end
  end
      
  it "sets deleted_at (Time.current) when deactivate! is called" do
    @user = User.make!
    @user.deactivate!
    @user.deleted_at.should be_true
  end
  
  it "unsets deleted_at (nil) when activate! is called" do
    @user = User.make!
    @user.update_attribute(:deleted_at, 1.month.ago)
    @user.activate!
    @user.deleted_at.should be_nil
  end
  
  describe "active_for_authentication?" do
    it "returns false if deleted_at is present" do
      @user = User.make!
      @user.update_attribute(:deleted_at, 1.month.ago)
      @user.should_not be_active_for_authentication
    end
    
    it "returns true if deleted_at is nil" do
      @user = User.make!
      @user.update_attribute(:deleted_at, nil)
      @user.should be_active_for_authentication
    end
  end
end
