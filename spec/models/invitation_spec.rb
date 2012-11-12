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

  describe "#accept!(user)" do
    it "adds an invited member to the group and marks the invitation as accepted" do
      @user = create(:user)
      @group = create(:group)
      invitation = build :invitation
      Group.stub(:find).and_return(@group)
      @group.should_receive(:add_member!).with(@user).and_return true
      invitation.should_receive(:accepted=).with(true)
      invitation.accept!(@user)
    end
  end
end
