require 'rails_helper'

describe MembershipsController do
  let(:group) { FactoryBot.create(:group) }
  let(:user) { FactoryBot.create(:user) }
  let(:another_group) { FactoryBot.create(:group) }
  let(:another_user) { FactoryBot.create(:user) }

  describe 'redeem' do
    let(:membership) { create :membership, group: group }

    before do
      session[:pending_membership_token] = membership.token
      sign_in user
    end

    # I dont belong to any groups, I follow a link and get added to the group
    # I belong to a group, but have an invitation to join it also, the membership is ignored
    # I have been invited to 2 groups in the same, org, I accept 1 membeship and it grants both
    it "pending membership" do
      expect(membership.accepted_at).to eq nil
      expect {get :consume}.to change { Event.count }.by(1)
      expect(response.status).to eq 200
      membership.reload
      expect(membership.accepted_at).not_to eq nil
      expect(membership.user_id).to eq user.id
    end

    it "multiple pending memberships - same org same user" do
      subgroup = create(:group, parent: membership.group)
      subgroup_membership = create(:membership, group: subgroup, user: membership.user)
      expect {get :consume}.to change { Event.count }.by(1)
      expect(response.status).to eq 200
      membership.reload
      subgroup_membership.reload
      expect(membership.accepted_at).not_to eq nil
      expect(membership.user_id).to eq user.id
      expect(subgroup_membership.accepted_at).not_to eq nil
      expect(subgroup_membership.user_id).to eq user.id
    end

    it "ignores when I already belong to the group" do
      group.add_member! user
      expect(membership.accepted_at).to eq nil
      expect {get :consume}.to_not change { Event.count }
      expect(response.status).to eq 200
      membership.reload
      expect(membership.accepted_at).to eq nil
      expect(membership.user_id).to_not eq user.id
    end

    it "does not redeem accepted membership" do
      membership.update(accepted_at: Time.zone.now)
      expect {get :consume}.not_to change { Event.count }
      expect(response.status).to eq 200
      membership.reload
      expect(membership.user_id).to_not eq user.id
    end
  end

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
        expect(response).to render_template "application/error"
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
