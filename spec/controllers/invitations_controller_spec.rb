require 'spec_helper'

describe InvitationsController do
  let(:group) { mock_model Group }
  let(:invitation) { mock_model Invitation, :token => "12345",
                                            :inviter => nil,
                                            :group_id => group.id }
  describe "#show" do
    before do
      Group.stub(:find).and_return(group)
      Invitation.stub(:where).
                 with(:group_id => group.id.to_s,
                      :token => invitation.token).
                 and_return([invitation])
    end
    context "invitation exists and has not been accepted" do
      before { invitation.stub(:accepted?).and_return false }
      it "sets the invitation session variable" do
        get :show, :group_id => group.id, :id => invitation.token
        session[:invitation].should eq(invitation.token)
      end
      context "user is signed in" do
        before do
          user = stub_model User
          sign_in user
          get :show, :group_id => group.id, :id => invitation.token
        end
        it "sets the flash success message" do
          flash[:success].should =~ /You have been added/
        end
        it "redirects to the group page" do
          response.should redirect_to(group_url(group))
        end
      end
    end
    context "invitation exists and but has been accepted" do
      before { invitation.stub(:accepted?).and_return true }
      it "renders the invitation invalid page" do
        get :show, :group_id => group.id, :id => invitation.token
        response.should render_template("invitation_accepted_error_page")
      end
    end
    context "invitation does not exist" do
      before { Invitation.stub(:where).and_return([]) }
      it "renders the invitation invalid page" do
        get :show, :group_id => group.id, :id => invitation.token
        response.should render_template("invitation_accepted_error_page")
      end
    end
  end
end