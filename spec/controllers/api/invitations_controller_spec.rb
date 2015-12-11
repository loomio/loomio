require 'rails_helper'
describe API::InvitationsController do
  include EmailSpec::Helpers
  include EmailSpec::Matchers

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:deactivated) { create :user, deactivated_at: 2.days.ago }
  let(:contact) { create :contact, user: user }
  let(:another_group) { create :group }
  let(:another_group_member) { create :user }
  let(:group) { create :group }
  let(:user_invitable)    { { id: another_user.id, type: :user } }
  let(:deactivated_invitable) { { id: deactivated.id, type: :user } }
  let(:group_invitable)   { { id: another_group.id, type: :group } }
  let(:contact_invitable) { { email: contact.email, type: :contact } }
  let(:email_invitable)   { { email: 'mail@gmail.com', type: :email } }
  let(:pending_invitation) { create :invitation, invitable: group }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    another_group.users << user
    another_group.users << another_user
    another_group.users << another_group_member
    pending_invitation
    sign_in user
  end

  describe 'create' do
    context 'success' do
      it 'creates invitations with custom message' do
        ActionMailer::Base.deliveries = []
        post :create, { group_id: group.id,
                        email_addresses: 'rob@example.com, hannah@example.com',
                        message: 'Please make decisions with us!' }
        json = JSON.parse(response.body)
        invitation = json['invitations'].last
        last_email = ActionMailer::Base.deliveries.last
        expect(ActionMailer::Base.deliveries.size).to eq 2
        expect(invitation['recipient_email']).to eq 'hannah@example.com'
        expect(last_email).to have_body_text 'Please make decisions with us!'
        expect(last_email).to deliver_to 'hannah@example.com'
      end

      it 'includes default message when no custom message' do
        post :create, { group_id: group.id,
                        email_addresses: 'rob@example.com, hannah@example.com' }
        json = JSON.parse(response.body)
        last_email = ActionMailer::Base.deliveries.last
        expect(last_email).to have_body_text "Click the link to join #{group.name} and get started:"
      end
    end

    # context 'failure' do
    #   it 'does not allow access to an unauthorized group' do
    #     cant_see_me = create :group
    #     expect { post :create, group_id: cant_see_me.id, invitations: [contact_invitable], format: :json }.to raise_error CanCan::AccessDenied
    #   end
    # end
  end

  describe 'shareable' do
    context 'permitted' do
      it 'gives a shareable link for the group' do
        get :shareable, group_id: group.id
        json = JSON.parse(response.body)
        expect(json['invitations'].first['single_use']).to eq false
      end
    end

    context 'not permitted' do
      it 'gives access denied' do
        sign_in another_user
        get :shareable, group_id: group.id
        expect(response.status).to eq 403
      end
    end
  end

  describe 'pending' do
    context 'permitted' do
      it 'returns invitations filtered by group' do
        get :pending, group_id: group.id
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[invitations])
        expect(json['invitations'].first['id']).to eq pending_invitation.id
      end
    end

    context 'not permitted' do
      it 'returns AccessDenied' do
        sign_in another_user
        get :pending, group_id: group.id
        expect(response.status).to eq 403
      end
    end
  end
end
