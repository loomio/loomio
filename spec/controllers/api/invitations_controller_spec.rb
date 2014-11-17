require 'rails_helper'
describe API::InvitationsController do

  let(:user) { create :user }
  let(:contact) { create :contact, user: user }
  let(:another_group) { create :group }
  let(:another_group_member) { create :user }
  let(:group) { create :group }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    another_group.users << user
    another_group.users << another_group_member
    sign_in user
  end

  describe 'create' do
    context 'success' do

      it 'creates a membership request for a user' do
        expect(MembershipService).to receive(:add_users_to_group)
        invitable = InvitableSerializer.new(another_group_member, root: false).as_json
        post :create, group_id: group.id, invitations: [invitable], invite_message: 'A user message', format: :json
        expect(assigns :user_ids).to include another_group_member.id
      end
      
      it 'creates membership requests for a group' do
        expect(MembershipService).to receive(:add_users_to_group)
        invitable = InvitableSerializer.new(another_group, root:false).as_json
        post :create, group_id: group.id, invitations: [invitable], invite_message: 'A group message', format: :json
        expect(assigns(:user_ids).flatten).to include another_group_member.id
      end

      it 'creates a invitation email for a contact' do
        expect(InvitationService).to receive(:invite_to_group)
        invitable = InvitableSerializer.new(contact, root: false).as_json
        post :create, group_id: group.id, invitations: [invitable], invite_message: 'A contact message', format: :json
        expect(assigns :contact_ids).to include contact.id
      end

      it 'creates an invitation email for a new email address' do
        expect(InvitationService).to receive(:invite_to_group)
        invitable = { type: 'Email', email: "biff@enspiral.org" }
        post :create, group_id: group.id, invitations: [invitable], invite_message: 'An email message', format: :json
        expect(assigns :new_emails).to include invitable[:email]
      end

    end

    context 'failure' do
      it 'does not allow access to an unauthorized group' do
        cant_see_me = create :group
        invitable = InvitableSerializer.new(contact).as_json
        expect { post :create, group_id: cant_see_me.id, invitations: [invitable], format: :json }.to raise_error CanCan::AccessDenied
      end
    end
  end

end
