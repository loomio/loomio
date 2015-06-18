require 'rails_helper'
describe API::ContactsController do

  describe 'index' do
    let(:user)    { create :user }
    let(:contact) { create :contact, user: user }

    before do
      sign_in user
      contact
    end

    context 'success' do

      it 'returns a list of current users contacts' do
        get :index, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[contacts])
        contact_ids = json['contacts'].map { |v| v['id'] }
        expect(contact_ids).to include contact.id       
      end

      it 'can search for contacts by name' do
        find_me = create :contact, user: user, name: 'borg_org'
        get :index, format: :json, q: 'borg'
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[contacts])
        contact_ids = json['contacts'].map { |v| v['id'] }
        expect(contact_ids).to include find_me.id
        expect(contact_ids).to_not include contact.id
      end

      it 'can search for contacts by email' do
        find_me = create :contact, user: user, name: 'borg@org.com'
        get :index, format: :json, q: 'borg'
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[contacts])
        contact_ids = json['contacts'].map { |v| v['id'] }
        expect(contact_ids).to include find_me.id
        expect(contact_ids).to_not include contact.id
      end

      it 'does not display contacts not visible to the current user' do
        cant_see_me = create :contact, name: 'borg_org'
        get :index, format: :json, q: 'borg'
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[contacts])
        contact_ids = json['contacts'].map { |v| v['id'] }
        expect(contact_ids).to_not include cant_see_me.id
      end

    end
  end

end
