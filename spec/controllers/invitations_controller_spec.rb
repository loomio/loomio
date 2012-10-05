require 'spec_helper'

describe InvitationsController do
  let(:group) { mock_model Group }
  let(:invitation) { mock_model Invitation }
  let(:token) { "12345" }
  describe "#show" do
    it "succeeds" do
      token = 12345
      Invitation.stub(:where).
                 with(:token => token,
                      :group_id => group.id).
                 and_return(invitation)
      get :show, :group_id => group.id, :id => token
      response.should be_successful
    end
    it "fails if invitation does not match up" do
      Invitation.stub(:where).
                 with(:token => token,
                      :group_id => group.id).
                 and_return([])
      get :show, :group_id => group.id, :id => token
      response.should be_redirect
    end
  end
end
