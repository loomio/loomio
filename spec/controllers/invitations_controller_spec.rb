require 'spec_helper'

describe InvitationsController do

  describe "GET 'show'" do

    let(:group) { stub_model(Group) }
    let(:invitation) {stub(:invitation,
                           :group => group,
                           :intent => 'join_group',
                           :cancelled? => false,
                           :accepted? => false)}

    context 'invitation not found' do
      render_views
      it 'renders error page with not found message' do
        get :show, id: 'asdjhadjkhaskjdsahda'
        response.body.should =~ /could not find invitation/i
      end
    end
    
    context "user not signed in" do
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
      before do
        Invitation.stub(:find_by_token).and_return(invitation)
        sign_in @user = FactoryGirl.create(:user)
      end

      context 'get with invitation token in query' do

        it "accepts invitation and redirects to group " do
          AcceptInvitation.should_receive(:and_grant_access!).with(invitation, @user)
          get :show, :id => 'asdfghjkl'
          response.should redirect_to group_path(group)
        end

      end

      context 'and has invitation_token in session' do
        before do
          session[:invitation_token] = 'abcdefg'
        end

        it 'accepts the invitation, redirects to group, and clears token from session' do
          AcceptInvitation.should_receive(:and_grant_access!).with(invitation, @user)
          get :show
          response.should redirect_to group_path(group)
          session[:invitation_token].should be_nil
        end
      end
    end
  end
end
