require 'spec_helper'

describe Invitation do
  it "generates unique random token upon create" do
    token, token2 = stub(:token), stub(:token2)
    invitation = build :invitation
    Invitation.stub_chain(:where, :exists?).and_return(true, false)
    SecureRandom.should_receive(:urlsafe_base64).twice.and_return token, token2
    invitation.should_receive(:token=).with(token2)
    invitation.save!
  end

  it "to_param returns token instead of id" do
    invitation = build :invitation
    invitation.stub(:token => "5235")
    invitation.to_param.should == invitation.token
  end

  describe "#active?" do
    before do
      @invitation = build :invitation
      @time_now = Time.now
      Time.stub(:now).and_return(time_now)
    end
    it "returns true if not expired" do
      @invitation.expirey = @time_now + 2.days
      @invitation.save
      @invitation.active?.should == true
    end
    it "returns false if expired" do
      @invitation.expirey = @time_now - 2.days
      @invitation.save!
      @invitation.active?.should == false
    end
  end

  describe "#add_invited_member(user)" do
    it "adds an invited member to the group and marks the invitation as expired" do
      time_now = Time.now
      Time.stub(:now).and_return(time_now)
      @user = create(:user)
      @group = create(:group)
      invitation = build :invitation
      Group.stub(:find).and_return(@group)
      @group.stub(:add_member!).with(@user)
      invitation.add_invited_member(@user)
    end
  end
end
