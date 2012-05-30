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
  
  describe "destroy and delete" do
    before(:each) do
      @user = User.make!
      @user_id = @user.id
    end
    
    it "does not delete the user" do
      @user.destroy
      deleted_user = User.find(@user_id)
      @user.should be_true
    end
    
    it "anonymises the user personal details" do
      email = @user.email
      name = @user.name
      @user.destroy
      deleted_user = User.find(@user_id)
      deleted_user.email.should_not == email
      deleted_user.name.should_not == name
    end
    
    it "makes sure that the hidden user is not an admin (security!)" do
      @user.destroy
      deleted_user = User.find(@user_id)
      deleted_user.should_not be_admin
    end
    
    it "ovverrides delete too" do
      @user.delete
      deleted_user = User.find(@user_id)
      @user.should be_true
    end
  end
end
