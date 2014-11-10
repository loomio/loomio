require 'rails_helper'
describe API::UsersController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:user_named_biff) { create :user, name: "Biff Bones" }
  let(:user_named_bang) { create :user, name: "Bang Whamfist" }
  let(:alien_named_biff) { create :user, name: "Biff Beef" }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment_params) {{
    body: 'Yo dawg those kittens be trippin for some dippin',
    discussion_id: discussion.id
  }}

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    group.users  << user_named_biff
    sign_in user
  end

  describe 'members' do

    context 'success' do
      it 'returns users filtered by query' do
        get :members, group_id: group.id, q: 'biff', format: :json
        json = JSON.parse(response.body)
        users = json['users'].map { |c| c['id'] }
        expect(users).to include user_named_biff.id
        expect(users).to_not include user_named_bang.id
        expect(users).to_not include alien_named_biff.id
      end
    end

    context 'failure' do
      it 'does not allow access to an unauthorized group' do
        cant_see_me = create :group
        expect { get :index, group_id: cant_see_me.id, format: :json }.to raise_error
      end
    end
  end

end
