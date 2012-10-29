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
      @group = mock_model Group
      @group.stub :creator=
      @group.stub :save!
      Group.stub :new => @group
      @mailer = double(:deliver => true)
      GroupMailer.stub :new_group_invited_to_loomio => @mailer
      @group_request = create :group_request
      @creator = mock_model User, :email => @group_request.admin_email
      User.stub :create! => @creator
    end

    it "should create a group with the group_request's attributes" do
      Group.should_receive(:new).with(:name => @group_request.name).
            and_return @group
      @group.should_receive(:creator=).with @creator
      @group.should_receive :save!
      @group_request.approve!
    end

    it "should send an instructional email (with invite token) to the admin of the group" do
      GroupMailer.should_receive(:new_group_invited_to_loomio).
        with(@group_request.admin_email, @group_request.name).
        and_return @mailer
      @mailer.should_receive(:deliver)
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
