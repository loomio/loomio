require 'rails_helper'
describe API::AnnouncementsController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:deactivated) { create :user, deactivated_at: 2.days.ago }
  let(:contact) { create :contact, user: user }
  let(:another_group) { create :formal_group }
  let(:another_group_member) { create :user }
  let(:group) { create :formal_group }
  let(:pending_invitation) { create :invitation, group: group }

  before do
    group.admins << user
    another_group.members << user
    another_group.members << another_user
    another_group.members << another_group_member
    pending_invitation
  end

  describe 'create' do
    let(:invitation_params) {{
      announcement: {
        kind: :membership_created,
        recipients: { emails: ['rob@example.com'] }
      },
      group_id: group.id
    }}

    context 'success' do
      it 'creates invitations' do
        sign_in user
        ActionMailer::Base.deliveries = []
        post :create, params: invitation_params
        json = JSON.parse(response.body)

        last_user = User.last
        expect(last_user.email).to eq 'rob@example.com'
        expect(last_user.email_verified).to eq false
        expect(group.members).to include last_user

        last_email = ActionMailer::Base.deliveries.last
        expect(last_email.to).to include 'rob@example.com'
        expect(ActionMailer::Base.deliveries.size).to eq 1
        expect(json['users_count']).to eq 1
      end
    end

    context 'failure' do
      it 'responds with unauthorized for non logged in users' do
        post :create, params: invitation_params
        expect(response.status).to eq 403
      end

      it 'responds with bad request if no emails are provided' do
        sign_in user
        invitation_params[:announcement][:recipients][:emails] = []
        post :create, params: invitation_params
        expect(response.status).to eq 400
      end

      it 'responds with validation error if max pending invites have been reached' do
        sign_in user
        ENV['MAX_PENDING_INVITATIONS'] = "5"
        10.times do
          m = FactoryBot.create(:membership, group: group)
          m.user.update(email_verified: false)
        end
        post :create, params: invitation_params
        expect(response.status).to eq 400
        ENV['MAX_PENDING_INVITATIONS'] = nil
      end
    end
  end

  describe 'shareable' do
    context 'permitted' do
      it 'gives a shareable link for the group' do
        get :shareable, params: { group_id: group.id }
        json = JSON.parse(response.body)
        expect(json['invitations'].first['single_use']).to eq false
      end
    end

    context 'not permitted' do
      it 'gives access denied' do
        sign_in another_user
        get :shareable, params: { group_id: group.id }
        expect(response.status).to eq 403
      end
    end
  end

  describe 'pending' do
    context 'permitted' do
      it 'returns invitations filtered by group' do
        get :pending, params: { group_id: group.id }
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[invitations])
        expect(json['invitations'].first['id']).to eq pending_invitation.id
      end
    end

    context 'not permitted' do
      it 'returns AccessDenied' do
        sign_in another_user
        get :pending, params: { group_id: group.id }
        expect(response.status).to eq 403
      end
    end
  end
end
