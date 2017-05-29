require 'rails_helper'

describe InvitationsController do
  let(:group) { FactoryGirl.create(:group) }
  let(:user) { FactoryGirl.create(:user) }
  let(:another_user) { create :user }
  let(:another_group) { FactoryGirl.create(:group) }
  let(:another_user) { FactoryGirl.create(:user) }

  before do
    group.add_admin!(user)
  end

  describe "GET 'show'" do
    let(:invitation) { create(:invitation, token: 'abc', invitable: group, recipient_email: user.email) }
    let(:start_group_invitation) { create :invitation, token: 'bcd', invitable: another_group, recipient_email: "something@something.com", intent: :start_group, to_be_admin: true }

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

    context 'with an associated identity' do
      before { group.community.update(identity: create(:slack_identity)) }

      it 'redirects to the group if a member' do
        group.add_member! another_user
        sign_in another_user
        get :show, id: invitation.token
        expect(response).to redirect_to group_url(group)
      end

      it 'redirects to the oauth path if not a member' do
        get :show, id: invitation.token
        expect(response).to redirect_to slack_oauth_url(back_to: group_url(group), team: invitation.slack_team_id)
      end
    end

    context "user not signed in" do
      before do
        get :show, id: invitation.token
      end

      it "sets session attribute of the invitation token" do
        expect(session[:pending_invitation_id]).to eq invitation.token
      end

      it "redirects to the group" do
        response.should redirect_to(group_url(invitation.group))
      end

      it 'does not accept the invitation' do
        InvitationService.should_not_receive(:redeem)
      end

    end

    context "to start group" do
      it 'creates a user' do
        start_group_invitation
        expect { get :show, id: start_group_invitation.token }.to change { User.count }.by(1)
        u = User.last
        expect(start_group_invitation.group.reload.admins).to include u
        expect(u.email).to eq start_group_invitation.recipient_email
      end

      it 'uses an existing user if one exists' do
        start_group_invitation.update(recipient_email: another_user.email)
        expect { get :show, id: start_group_invitation.token }.to_not change { User.count }
        expect(start_group_invitation.group.reload.admins).to include another_user
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
          expect(Membership.find_by(group: group, user: user)).to be_present
          response.should redirect_to group_url(group)
        end

      end

      context 'and has invitation_token in session' do
        before do
          session[:pending_invitation_id] = invitation.token
        end

        it 'accepts the invitation, redirects to group, and clears token from session' do
          get :show, id: invitation.token
          response.should redirect_to group_url(group)
          invitation.reload
          expect(invitation.accepted?).to be true
          expect(Membership.find_by(group: group, user: user)).to be_present
          session[:pending_invitation_id].should be_nil
        end
      end
    end
  end
end
