require 'spec_helper'

describe InvitationsController do

  describe "GET 'show'" do
    #User visits invitation/token
    #
    #if they are signed in
      #accept invitation from user with token
      #forward to group they have been invited to
    #if they are not signed in
      #set session attribute: invitation_token
      #render invited_but_please_sign_in
    
    context "user not signed in" do
      before do
        get :show, :id => 'asdfghjkl'
      end

      it "sets session attribute of the invitation token" do 
        session[:invitation_token].should == "asdfghjkl" 
      end

      it "renders sign in page" do
        response.should render_template 'please_sign_in'
      end

      it 'does not accept the invitation' do
        AcceptInvitation.should_not_receive(:from_user_with_token)
      end
    end

    context "user is signed in" do
      let(:group) { stub_model(Group) }
      let(:invitation) {stub(:invitation, :group => group)}
      before do
        sign_in @user = FactoryGirl.create(:user)
        AcceptInvitation.should_receive(:from_user_with_token).with(@user, 'asdfghjkl').and_return(invitation)
      end

      it "accepts invitation from user" do
        get :show, :id => 'asdfghjkl'
      end

      it "forwards user to group" do
        get :show, :id => 'asdfghjkl'
        response.should redirect_to group_path(group)
      end
    end
  end


end
