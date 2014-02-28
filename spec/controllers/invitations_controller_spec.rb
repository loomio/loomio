require 'spec_helper'

describe InvitationsController do
  before do
    @group = FactoryGirl.create(:group)
    @user = FactoryGirl.create(:user)
    @group.add_admin!(@user)
  end

  describe 'destroy' do
    let(:invitation){double(:invitation,
                            recipient_email: 'jim@jam.com',
                            cancel!: true,
                            group: @group)}

    before do
      sign_in @user
      Invitation.stub(:find_by_token!).and_return(invitation)
    end

    it 'cancels the invitation' do
      controller.should_receive(:authorize!).with(:cancel, invitation)
      invitation.should_receive(:cancel!).with(canceller: @user)
      delete :destroy, group_id: @group.key
      response.should redirect_to group_memberships_path(@group)
    end
  end

  describe "GET 'show'" do
    let(:group) { stub_model(Group, key: 'AaBC1256', full_name: "Gertrude's Emportium") }
    let(:invitation) {double(:invitation,
                             :invitable => group,
                             :invitable_type => 'Group',
                             :recipient_email => 'jim@bob.com',
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
        Invitation.should_receive(:find_by_token!).and_return(invitation)
        get :show, :id => 'AaBC1256'
      end

      it "sets session attribute of the invitation token" do
        session[:invitation_token].should == "AaBC1256"
      end

      it "redirects to sign up" do
        response.should redirect_to new_user_registration_path
      end

      it 'does not accept the invitation' do
        AcceptInvitation.should_not_receive(:and_grant_access!)
      end

    end

    context "user is signed in" do
      before do
        Invitation.stub(:find_by_token!).and_return(invitation)
        sign_in @user = FactoryGirl.create(:user)
      end

      context 'get with invitation token in query' do

        it "accepts invitation and redirects to group " do
          AcceptInvitation.should_receive(:and_grant_access!).with(invitation, @user)
          get :show, :id => 'AaBC1256'
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
