require 'rails_helper'
describe 'ContactRequestService' do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create(:group) }
  let(:contact_request) { ContactRequest.new(message: 'a contact request', recipient_id: another_user.id) }

  before { group.add_member! user }

  describe 'create' do
    it 'sends an email if you can contact the user' do
      group.add_member! another_user
      expect {
        ContactRequestService.create(contact_request: contact_request, actor: user)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not send an email if you cannot contact the user' do
      expect {
        ContactRequestService.create(contact_request: contact_request, actor: user)
      }.to raise_error { CanCan::AccessDenied }
    end
  end
end
