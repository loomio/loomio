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
end
