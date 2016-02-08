require 'rails_helper'

describe InvitationsController do
  let(:group) { FactoryGirl.create(:group) }
  let(:user) { FactoryGirl.create(:user) }

  before do
    group.add_admin!(user)
  end

  describe 'destroy' do
    let(:invitation){create(:invitation, invitable: group)}

    before do
      sign_in user
    end

    it 'cancels the invitation' do
      delete :destroy, id: invitation.token, group_id: group.key
      response.should redirect_to group_memberships_path(group)
      invitation.reload
      expect(invitation.cancelled?).to be true
    end
  end

  describe "GET 'show'" do
    let(:group) { create(:group) }
    let(:invitation) { create(:invitation, token: 'abc', invitable: group, recipient_email: user.email) }

    context 'invitation not found' do
      render_views
      it 'renders error page with not found message' do
        get :show, id: 'asdjhadjkhaskjdsahda'
        expect(response.body).to match(/could not find invitation/i)
      end
    end

    context 'invitation used' do
      render_views
      before do
        sign_in user
        invitation.update_attribute(:accepted_at, Time.now)
      end

      it 'says sorry invitatino already used' do
        get :show, id: invitation.token
        expect(response).to redirect_to(invitation.invitable)
      end
    end

    context "user not signed in" do
      before do
        get :show, id: invitation.token
      end

      it "sets session attribute of the invitation token" do
        expect(session[:invitation_token]).to eq invitation.token
      end

      it "redirects to sign in" do
        response.should redirect_to(new_user_session_path(email: invitation.recipient_email))
      end

      it 'does not accept the invitation' do
        InvitationService.should_not_receive(:redeem)
      end

    end

    context "user is signed in" do
      before do
        sign_in @user = FactoryGirl.create(:user)
      end

      context 'get with invitation token in query' do

        it "accepts invitation and redirects to group " do
          get :show, id: invitation.token
          invitation.reload
          expect(invitation.accepted?).to be true
          expect(group.has_member?(user)).to be true
          response.should redirect_to group_path(group)
        end

      end

      context 'and has invitation_token in session' do
        before do
          session[:invitation_token] = invitation.token
        end

        it 'accepts the invitation, redirects to group, and clears token from session' do
          get :show, id: invitation.token
          response.should redirect_to group_path(group)
          invitation.reload
          expect(invitation.accepted?).to be true
          expect(group.has_member?(user)).to be true
          session[:invitation_token].should be_nil
        end
      end
    end
  end
end
