require 'spec_helper'

describe GroupRequest do
  let(:user) { create(:user) }

  before do
    StartGroupMailer.stub_chain(:verification, :deliver)
    @group_request = build(:group_request)
  end

  describe 'destroy' do
    before do
      @group_request = FactoryGirl.create(:group_request)
    end

    it 'returns normaly (ie: itself)' do
      @group_request.destroy.should == @group_request
    end

    context 'if group present?' do
      before do
        @group_request.group = FactoryGirl.create(:group)
      end

      it 'returns false if group associated' do
        @group_request.destroy.should be_false
      end
    end
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
      @group_request.approve!(approved_by: user)
      @group_request.should be_approved
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
      @group_request.approve!(approved_by: user)
      @group_request.should be_approved
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
      @group_request.approve!(approved_by: user)
      @group_request.should be_approved
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
      @group_request.approve!(approved_by: user)
      @group_request.should be_approved
    end

    it "can later be changed to verified" do
      @group_request.verify!
      @group_request.should be_verified
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

  context "#self.check_defered" do
    before do
      @group_request = create(:group_request)
      @group_request1 = create(:group_request)
      @group_request.verify!
      @group_request1.verify!
      @group_request.defer!
      @group_request1.defer!
      @group_request.defered_until = Time.now + 2.days
      @group_request1.defered_until = Time.now - 2.days
      @group_request.save!
      @group_request1.save!
    end

    it "should return expired defered group_requests to verified" do
      GroupRequest.check_defered
      GroupRequest.find(@group_request.id).should be_defered
      GroupRequest.find(@group_request1.id).should be_verified
    end
  end
end
