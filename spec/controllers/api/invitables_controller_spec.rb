require 'rails_helper'
describe API::InvitablesController do

  let(:user) { create :user }
  let(:contact_named_biff) { create :contact, user: user, name: "Biff Boink" }
  let(:contact_named_bang) { create :contact, user: user, name: "Bang Wharf" }
  let(:contact_email_biff) { create :contact, user: user, email: "biff@wark.com" }
  let(:user_named_biff) { create :user, name: "Biff Bones" }
  let(:user_last_named_biff) { create :user, name: "Bones Biff" }
  let(:same_group_biff) { create :user, name: "Biff Bomb" }
  let(:user_username_biff) { create :user, username: 'biffcake' }
  let(:user_named_bang) { create :user, name: "Bang Whamfist" }
  let(:alien_named_biff) { create :user, name: "Biff Beef" }
  let(:group) { create :group }
  let(:group_named_biff) { create :group, name: "Biff Arang" }
  let(:group_named_bang) { create :group, name: "Bang Arang" }
  let(:hidden_named_biff) { create :group, name: "Biff Ahoy" }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    group.users << same_group_biff
    group_named_biff.users << [user, user_named_biff, user_named_bang, user_last_named_biff, user_username_biff]
    group_named_bang.users << user
    sign_in user
  end

  describe 'index' do

    context 'success' do

      it 'returns a users contacts filtered by query on name' do
        contact_named_biff; contact_named_bang
        get :index, group_id: group.id, q: 'biff', format: :json

        names = invitation_names_from response
        expect(names).to     include contact_named_biff.name
        expect(names).to_not include contact_named_bang.name
      end

      it 'returns a users contacts filtered by query on email' do
        contact_email_biff; contact_named_bang
        get :index, group_id: group.id, q: 'biff', format: :json

        names = invitation_names_from response
        expect(names).to     include contact_email_biff.name
        expect(names).to_not include contact_named_bang.name
      end

      it 'returns a users groups filtered by query' do
        get :index, group_id: group.id, q: 'biff', format: :json

        names = invitation_names_from response
        expect(names).to     include group_named_biff.name
        expect(names).to_not include group_named_bang.name
      end

      it 'returns a users relations filtered by query on first name' do
        user_named_biff; user_named_bang
        get :index, group_id: group.id, q: 'biff', format: :json

        names = invitation_names_from response
        expect(names).to     include user_named_biff.name
        expect(names).to_not include user_named_bang.name
      end

      it 'returns a users relations filtered by query on last name' do
        user_last_named_biff; user_named_bang
        get :index, group_id: group.id, q: 'biff', format: :json

        names = invitation_names_from response
        expect(names).to     include user_last_named_biff.name
        expect(names).to_not include user_named_bang.name
      end

      it 'returns a users relations filtered by query on username' do
        user_username_biff; user_named_bang
        get :index, group_id: group.id, q: 'biff', format: :json

        names = invitation_names_from response
        expect(names).to     include user_username_biff.name
        expect(names).to_not include user_named_bang.name
      end 

      it "does not returns users from the same group" do
        same_group_biff
        get :index, group_id: group.id, q: 'biff', format: :json

        names = invitation_names_from response
        expect(names).to_not include same_group_biff.name
      end      
    end

    context 'failure' do
      it 'does not allow access to an unauthorized group' do
        cant_see_me = create :group
        get :index, group_id: cant_see_me.id
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end
    end
  end

  def invitation_names_from(response)
    json = JSON.parse(response.body)
    expect(json.keys).to include *(%w[invitables])
    json['invitables'].map { |i| i['name'] }
  end

end
