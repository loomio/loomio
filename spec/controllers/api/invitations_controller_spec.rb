require 'rails_helper'
describe API::InvitationsController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:deactivated) { create :user, deactivated_at: 2.days.ago }
  let(:contact) { create :contact, user: user }
  let(:another_group) { create :formal_group }
  let(:another_group_member) { create :user }
  let(:group) { create :formal_group }
  let(:pending_invitation) { create :invitation, group: group }
  let(:invitation_params)  { { emails: 'rob@example.com, hannah@example.com' } }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    another_group.members << user
    another_group.members << another_user
    another_group.members << another_group_member
    pending_invitation
    sign_in user
  end

  describe 'create' do
    context 'success' do
      it 'creates invitations' do
        ActionMailer::Base.deliveries = []
        post :bulk_create, params: { invitation_form: invitation_params, group_id: group.id }
        json = JSON.parse(response.body)
        invitation = json['invitations'].last
        last_email = ActionMailer::Base.deliveries.last
        expect(ActionMailer::Base.deliveries.size).to eq 2
        expect(invitation['recipient_email']).to eq 'hannah@example.com'
        expect(last_email.to).to include 'hannah@example.com'
      end
    end

    context 'failure' do
      it 'responds with unauthorized for non logged in users' do
        @controller.stub(:current_user).and_return(LoggedOutUser.new)
        post :bulk_create, params: { invitation_form: invitation_params, group_id: group.id }
        expect(response.status).to eq 403
      end

      it 'responds with bad request if no emails are provided' do
        post :bulk_create, params: {invitation_form: {}, group_id: group.id}
        expect(response.status).to eq 400
      end

      it 'responds with validation error if max pending invites have been reached' do
        ENV['MAX_PENDING_INVITATIONS'] = "5"
        5.times { group.invitations.create!(intent: :join_group, recipient_email: Faker::Internet.email) }
        post :bulk_create, params: { invitation_form: invitation_params, group_id: group.id }
        expect(response.status).to eq 422
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
