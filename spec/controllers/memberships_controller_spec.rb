require 'rails_helper'

describe MembershipsController do
  let(:group) { FactoryBot.create(:group) }
  let(:user) { FactoryBot.create(:user) }
  let(:another_group) { FactoryBot.create(:group) }
  let(:another_user) { FactoryBot.create(:user) }

  describe "join" do
    it "store pending_group_token in session" do
      get :join, params: {model: 'group', token: group.token}
      expect(session[:pending_group_token]).to eq group.token
      expect(response).to redirect_to(group_url(group))
    end
  end

  describe "GET 'show'" do
    let(:membership) { create(:membership, token: 'abc', group: group, user: user) }

    context 'membership not found' do
      it 'renders error page with not found message' do
        get :show, params: { token: 'asdjhadjkhaskjdsahda' }
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
        get :show, params: { token: membership.token }
        expect(response).to redirect_to(group_url(membership.group))
      end
    end

    context 'with an associated identity' do
      before { group.group_identities.create(identity: create(:slack_identity)) }

      it 'redirects to the group if a member' do
        group.add_member! another_user
        sign_in another_user
        get :show, params: { token: membership.token }
        expect(response).to redirect_to group_url(group)
      end
    end

    context "user not signed in" do
      before do
        get :show, params: { token: membership.token }
      end

      it "sets session attribute of the membership token" do
        expect(session[:pending_membership_token]).to eq membership.token
      end

      it "redirects to the group" do
        response.should redirect_to(group_url(membership.group))
      end

      it 'does not accept the membership' do
        MembershipService.should_not_receive(:redeem)
      end

    end

    it 'redirects to a group url if that token is given' do
      get :show, params: { token: group.token }
      expect(response).to redirect_to join_url(group)
    end

    it "accepts membership and redirects to group " do
      get :show, params: { token: membership.token }
      membership.reload
      expect(membership.accepted_at).to_not be_present
      response.should redirect_to group_url(group)
    end
  end
end
