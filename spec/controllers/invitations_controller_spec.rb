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
      let(:invitation){stub(:invitation, intent: 'join_group')}
      before do
        Invitation.should_receive(:find_by_token).and_return(invitation)
        get :show, :id => 'asdfghjkl'
      end

      it "sets session attribute of the invitation token" do 
        session[:invitation_token].should == "asdfghjkl" 
      end

      it "renders sign in page" do
        response.should render_template 'invitations/join_group'
      end

      it 'does not accept the invitation' do
        AcceptInvitation.should_not_receive(:and_grant_access!)
      end

    end

    context "user is signed in" do
      let(:group) { stub_model(Group) }
      let(:invitation) {stub(:invitation, :group => group)}
      before do
        sign_in @user = FactoryGirl.create(:user)
      end

      context '' do
        before do
          Invitation.should_receive(:find_by_token).and_return(invitation)
          AcceptInvitation.should_receive(:and_grant_access!).with(invitation, @user)
        end

        it "accepts invitation from user" do
          get :show, :id => 'asdfghjkl'
        end

        it "forwards user to group" do
          get :show, :id => 'asdfghjkl'
          response.should redirect_to group_path(group)
        end

      end

      context 'and has invitation_token in session' do
        before do
          session[:invitation_token] = 'abcdefg'
          Invitation.should_receive(:find_by_token).and_return(invitation)
          AcceptInvitation.should_receive(:and_grant_access!).with(invitation, @user)
          get :show
        end

        it 'accepts the invitation and redirects them to the group page' do
          response.should redirect_to group_path(group)
        end

        it 'removes invitation token from the session' do
          session[:invitation_token].should be_nil
        end
      end
    end
  end
end
