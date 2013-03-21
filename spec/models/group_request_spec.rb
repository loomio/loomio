require 'spec_helper'

describe GroupRequest do
  let(:group_request) { create :group_request }

  describe "#status" do
    it "should default to awaiting_approval" do
      group_request.should be_awaiting_approval
    end
  end

  it "marks spam as spam" do
    group_request = create :group_request, :robot_trap => "spammy"
    group_request.save
    group_request.should be_marked_as_spam
  end

  describe "#sectors_metric" do
    it "returns an array" do
      group_request.sectors_metric = ["community", "business"]
      group_request.save
      group_request.reload
      group_request.sectors_metric[0].should == "community"
      group_request.sectors_metric[1].should == "business"
    end
  end

  it "should have 'other_sector' string field" do
    group_request.other_sectors_metric = "logging"
    group_request.save
    group_request.other_sectors_metric.should == "logging"
  end

  describe "#approve!" do
    let(:invitation) { stub :token => "1234" }
    let(:group) { mock_model Group }
    let(:mailer) { stub :deliver => true }

    before do
      Group.stub :new => group
      group.stub :creator=
      group.stub :creator => stub(:user)
      group.stub :cannot_contribute=
      group.stub :max_size=
      group.stub :distribution_metric=
      group.stub :sectors_metric=
      group.stub :other_sectors_metric=
      group.stub :create_welcome_loomio
      group.stub :save!
      StartGroupMailer.stub_chain(:invite_admin_to_start_group, :deliver)
    end

    it "should create a group with the group_request's attributes" do
      Group.should_receive(:new).with(:name => group_request.name).
            and_return(group)
      group.should_receive(:creator=)
      group.should_receive(:cannot_contribute=)
      group.should_receive(:max_size=)
      group.should_receive(:distribution_metric=)
      group.should_receive(:sectors_metric=)
      group.should_receive(:other_sectors_metric=)
      group.should_receive(:create_welcome_loomio)
      group.should_receive(:save!)
      group_request.approve!
    end

    it "should invite the admin to the group" do
      StartGroupMailer.should_receive(:invite_admin_to_start_group).
                          with(group_request)
      group_request.approve!
    end

    it "should link to the newly created group" do
      group_request.approve!
      group_request.group_id.should eq(group.id)
    end

    it "should set the status to approved" do
      group_request.approve!
      group_request.should be_approved
    end
  end

  describe "#accept!(user)" do
    let(:group) { mock_model(Group) }
    let(:user) { stub(:user) }

    before do
      group.stub(:add_admin!)
      group_request.status = :approved
      group_request.group = group
    end

    it "makes the user an admin of the group" do
      group.should_receive(:add_admin!).with(user)
      group_request.accept!(user)
    end

    it "sets the status to accepted" do
      group_request.accept!(user)
      group_request.should be_accepted
    end
  end

  describe "#ignore!" do
    it "should set the status to ignored" do
      group_request.ignore!
      group_request.should be_ignored
    end
  end

  context "that has been ignored" do
    it "can later be approved" do
      group_request.ignore!
      group_request.should_receive(:approve_request)
      group_request.approve!
    end
  end

  describe "#mark_as_spam!" do
    it "should set the status to marked_as_spam" do
      group_request.mark_as_spam!
      group_request.should be_marked_as_spam
    end
  end
end
