require 'rails_helper'
describe API::InvitationsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:contact) { create :contact, user: user }
  let(:another_group) { create :group }
  let(:another_group_member) { create :user }
  let(:group) { create :group }
  let(:user_invitable)    { { id: another_user.id, type: :user } }
  let(:group_invitable)   { { id: another_group.id, type: :group } }
  let(:contact_invitable) { { email: contact.email, type: :contact } }
  let(:email_invitable)   { { email: 'mail@gmail.com', type: :email } }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    another_group.users << user
    another_group.users << another_user
    another_group.users << another_group_member
    sign_in user
  end

  describe 'create' do
    context 'success' do

      it 'creates a membership invitation for a user' do
        post :create, group_id: group.id, invitations: [user_invitable], invite_message: 'A user message', format: :json
        expect(group.members.pluck(:id)).to include another_user.id
      end
      
      it 'creates membership invitation for all members of a group' do
        post :create, group_id: group.id, invitations: [group_invitable], invite_message: 'A group message', format: :json
        expect(group.members.pluck(:id)).to include another_user.id
        expect(group.members.pluck(:id)).to include another_group_member.id
      end

      it 'creates a invitation email for a contact' do
        post :create, group_id: group.id, invitations: [contact_invitable], invite_message: 'A contact message', format: :json
        expect(group.invitations.find_by(recipient_email: contact.email, inviter: user)).to be_present
      end

      it 'creates an invitation email for a new email address' do
        InvitePeopleMailer.stub_chain(:delay, :to_join_group)
        post :create, group_id: group.id, invitations: [email_invitable], invite_message: 'An email message', format: :json
        expect(group.invitations.find_by(recipient_email: email_invitable[:email], inviter: user)).to be_present
      end

    end

    # context 'failure' do
    #   it 'does not allow access to an unauthorized group' do
    #     cant_see_me = create :group
    #     expect { post :create, group_id: cant_see_me.id, invitations: [contact_invitable], format: :json }.to raise_error CanCan::AccessDenied
    #   end
    # end
  end

end
