require 'spec_helper'

describe GroupRequest do
  describe "#status" do
    it "should default to awaiting_approval" do
      @group_request = create :group_request
      @group_request.should be_awaiting_approval
    end
  end

  describe "#approve!" do
    before do
      @group_request = create :group_request
      @creator = mock_model User, :email => @group_request.admin_email
      @group = mock_model Group
      @group.stub :creator=
      @group.stub :creator => stub(:user)
      @group.stub :cannot_contribute=
      @group.stub :save!
      Group.stub :new => @group
      User.stub :create! => @creator
      InvitesUsersToGroup.stub :invite!
    end

    it "should create a group with the group_request's attributes" do
      Group.should_receive(:new).with(:name => @group_request.name).
            and_return @group
      @group.should_receive(:creator=).with @creator
      @group.should_receive(:cannot_contribute=)
      @group.should_receive :save!
      @group_request.approve!
    end

    it "should invite the admin to the group" do
      InvitesUsersToGroup.should_receive(:invite!).
        with(:recipient_emails => [@group_request.admin_email],
             :inviter => @group.creator,
             :group => @group,
             :access_level => "admin")
      @group_request.approve!
    end

    it "should link to the newly created group" do
      @group_request.approve!
      @group_request.group_id.should eq(@group.id)
    end

    it "should set the status to approved" do
      @group_request.approve!
      @group_request.should be_approved
    end
  end

  describe "#ignore!" do
    it "should set the status to ignored" do
      @group_request = create :group_request
      @group_request.ignore!
      @group_request.should be_ignored
    end
  end

  context "that has been ignored" do
    it "can later be approved" do
      @group_request = create :group_request
      @group_request.ignore!
      @group_request.approve!
      @group_request.should be_approved
    end
  end
end
