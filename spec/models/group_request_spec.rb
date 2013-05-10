require 'spec_helper'

describe GroupRequest do
  let(:user) { create(:user) }

  before do
    StartGroupMailer.stub_chain(:verification, :deliver)
    @group_request = build(:group_request)
  end

  it "should have 'other_sector' string field" do
    @group_request.other_sector = "logging"
    @group_request.save
    @group_request.other_sector.should == "logging"
  end

  describe "#status" do
    it "should default to unverified" do
      @group_request.save!
      @group_request.should be_unverified
    end
  end

  it "marks spam as spam" do
    @group_request.robot_trap = "spammy"
    @group_request.save
    @group_request.should be_marked_as_spam
  end

  describe "#verify!" do
    before { @group_request.save! }
    it "should set the status to verified" do
      @group_request.verify!
      @group_request.should be_verified
    end
  end

  describe "#accept!(user)" do
    let(:group) { mock_model(Group) }

    before do
      group.stub(:add_admin!)
      @group_request.status = :approved
      @group_request.group = group
      @group_request.save!
    end

    it "makes the user an admin of the group" do
      group.should_receive(:add_admin!).with(user)
      @group_request.accept!(user)
    end

    it "sets the status to accepted" do
      @group_request.accept!(user)
      @group_request.should be_accepted
    end
  end

  describe "#defer!" do
    before do
      @group_request.save!
      @group_request.verify!
    end

    it "should set the status to defered" do
      @group_request.defer!
      @group_request.should be_defered
    end
  end

  describe "#marked_as_manually_approved!" do
    before { @group_request.save! }
    it "should set the status to manually_approved" do
      @group_request.mark_as_manually_approved!
      @group_request.should be_manually_approved
    end
  end

  describe "#mark_as_spam!" do
    before { @group_request.save! }
    it "should set the status to marked_as_spam" do
      @group_request.mark_as_spam!
      @group_request.should be_marked_as_spam
    end
  end

  describe "#mark_as_unverified!" do
    before do
      @group_request.save!
      @group_request.mark_as_spam!
    end

    it "should set the status to unverified" do
      @group_request.mark_as_unverified!
      @group_request.should be_unverified
    end
  end

  context "that has been verified" do
    before do
      @group_request.save!
      @group_request.verify!
    end

    it "can later be approved" do
      @group_request.should_receive(:approve_request!)
      @group_request.approve!(approved_by: user)
    end

    it "can set the status to marked_as_smanually_approved" do
      @group_request.mark_as_manually_approved!
      @group_request.should be_manually_approved
    end

    it "can set the status to marked_as_spam" do
      @group_request.mark_as_spam!
      @group_request.should be_marked_as_spam
    end
  end

  context "that has been defered" do
    before do
      @group_request.save!
      @group_request.verify!
      @group_request.defer!
    end

    it "can later be approved" do
      @group_request.should_receive(:approve_request!)
      @group_request.approve!(approved_by: user)
    end

    it "can later be marked as manually_approved" do
      @group_request.mark_as_manually_approved!
      @group_request.should be_manually_approved
    end

    it "can set the status to marked_as_spam" do
      @group_request.mark_as_spam!
      @group_request.should be_marked_as_spam
    end
  end

  context "that has been manually_approved" do
    before do
      @group_request.save!
      @group_request.mark_as_manually_approved!
    end

    it "can set the status to unverified" do
      @group_request.mark_as_unverified!
      @group_request.should be_unverified
    end
  end

  context "that has been marked_as_spam" do
    before do
      @group_request.save!
      @group_request.mark_as_spam!
    end

    it "can set the status to unverified" do
      @group_request.mark_as_unverified!
      @group_request.should be_unverified
    end
  end

  describe "#mark_as_spam!" do
    before { @group_request.save! }
    it "should set the status to marked_as_spam" do
      @group_request.mark_as_spam!
      @group_request.should be_marked_as_spam
    end
  end

  describe "#mark_as_unverified!" do
    before do
      @group_request.save!
      @group_request.mark_as_spam!
    end

    it "should set the status to unverified" do
      @group_request.mark_as_unverified!
      @group_request.should be_unverified
    end
  end

  context "that has been verified" do
    before do
      @group_request.save!
      @group_request.verify!
    end

    it "can later be approved" do
      @group_request.should_receive(:approve_request!)
      @group_request.approve!(approved_by: user)
    end

    it "can set the status to marked_as_smanually_approved" do
      @group_request.mark_as_manually_approved!
      @group_request.should be_manually_approved
    end

    it "can set the status to marked_as_spam" do
      @group_request.mark_as_spam!
      @group_request.should be_marked_as_spam
    end
  end

  context "that has been defered" do
    before do
      @group_request.save!
      @group_request.verify!
      @group_request.defer!
    end

    it "can later be approved" do
      @group_request.should_receive(:approve_request!)
      @group_request.approve!(approved_by: user)
    end

    it "can later be marked as manually_approved" do
      @group_request.mark_as_manually_approved!
      @group_request.should be_manually_approved
    end

    it "can set the status to marked_as_spam" do
      @group_request.mark_as_spam!
      @group_request.should be_marked_as_spam
    end
  end

  context "that has been manually_approved" do
    before do
      @group_request.save!
      @group_request.mark_as_manually_approved!
    end

    it "can set the status to unverified" do
      @group_request.mark_as_unverified!
      @group_request.should be_unverified
    end
  end

  context "that has been marked_as_spam" do
    before do
      @group_request.save!
      @group_request.mark_as_spam!
    end

    it "can set the status to unverified" do
      @group_request.mark_as_unverified!
      @group_request.should be_unverified
    end
  end
end
