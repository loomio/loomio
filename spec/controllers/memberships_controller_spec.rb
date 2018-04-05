require 'rails_helper'

describe MembershipsController do
  let(:group) { FactoryBot.create(:formal_group) }
  let(:user) { FactoryBot.create(:user) }
  let(:another_group) { FactoryBot.create(:formal_group) }
  let(:another_user) { FactoryBot.create(:user) }

  before do
    group.add_admin!(user)
  end

  describe "GET 'show'" do
    let(:membership) { create(:membership, token: 'abc', group: group, user: user) }

    context 'membership not found' do
      it 'renders error page with not found message' do
        get :show, params: { id: 'asdjhadjkhaskjdsahda' }
        expect(response.status).to eq 404
        expect(response).to render_template "errors/404"
      end
    end

    context 'membership used' do
      before do
        sign_in user
        membership.update_attribute(:accepted_at, Time.now)
      end

      it 'says sorry invitatino already used' do
        get :show, params: { id: membership.token }
        expect(response).to redirect_to(group_url(membership.group, invitation_token: membership.token))
      end
    end

    context 'with an associated identity' do
      before { group.group_identities.create(identity: create(:slack_identity)) }

      it 'redirects to the group if a member' do
        group.add_member! another_user
        sign_in another_user
        get :show, params: { id: membership.token }
        expect(response).to redirect_to group_url(group, invitation_token: membership.token)
      end
    end

    context "user not signed in" do
      before do
        get :show, params: { id: membership.token }
      end

      it "sets session attribute of the membership token" do
        expect(session[:pending_invitation_id]).to eq membership.token
      end

      it "redirects to the group" do
        response.should redirect_to(group_url(membership.group, invitation_token: membership.token))
      end

      it 'does not accept the membership' do
        InvitationService.should_not_receive(:redeem)
      end

    end

    context "user is signed in" do
      before do
        sign_in @user = FactoryBot.create(:user)
      end

      context 'get with membership token in query' do

        it "accepts membership and redirects to group " do
          get :show, params: { id: membership.token }
          membership.reload
          expect(membership.accepted?).to be true
          expect(Membership.find_by(group: group, user: user)).to be_present
          response.should redirect_to group_url(group, invitation_token: membership.token)
        end

      end

      context 'and has invitation_token in session' do
        before do
          session[:pending_invitation_id] = membership.token
        end

        it 'accepts the membership, redirects to group, and clears token from session' do
          get :show, params: { id: membership.token }
          response.should redirect_to group_url(group, invitation_token: membership.token)
          membership.reload
          expect(membership.accepted?).to be true
          expect(Membership.find_by(group: group, user: user)).to be_present
          session[:pending_invitation_id].should be_nil
        end
      end
    end
  end
end
