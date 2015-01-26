require 'rails_helper'
describe API::MembershipsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:user_named_biff) { create :user, name: "Biff Bones" }
  let(:user_named_bang) { create :user, name: "Bang Whamfist" }
  let(:alien_named_biff) { create :user, name: "Biff Beef" }
  let(:group) { create :group }
  let(:biggroup) { create :group }
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

    # group will be created with one member already, so by adding 1 admin
    # and 4 others, we should end with 6.
    biggroup.admins << user
    biggroup.users << [another_user, user_named_biff, user_named_bang, alien_named_biff]
  end

  describe 'index' do 
    context 'success' do
      it 'returns users filtered by group' do
        get :index, group_id: group.id, format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users memberships groups])
        users = json['users'].map { |c| c['id'] }
        groups = json['groups'].map { |g| g['id'] }
        expect(users).to include user_named_biff.id
        expect(users).to_not include alien_named_biff.id
        expect(groups).to include group.id
      end
      it 'returns all members of a big group' do
        get :index, group_id: biggroup.id, format: :json
        json = JSON.parse(response.body)
        puts json['users']
        expect(json['users'].length).to eq 6
      end
      it 'limits members when limited' do
        get :index, group_id: biggroup.id, limit: 2, format: :json
        json = JSON.parse(response.body)
        expect(json['users'].length).to eq 2
      end
    end
  end

  describe 'autocomplete' do
    context 'success' do
      it 'returns users filtered by query' do
        get :autocomplete, group_id: group.id, q: 'biff', format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users memberships groups])
        users = json['users'].map { |c| c['id'] }
        groups = json['groups'].map { |g| g['id'] }
        expect(users).to include user_named_biff.id
        expect(users).to_not include user_named_bang.id
        expect(users).to_not include alien_named_biff.id
        expect(groups).to include group.id
      end
    end

    context 'failure' do
      it 'does not allow access to an unauthorized group' do
        cant_see_me = create :group
        get :autocomplete, group_id: cant_see_me.id
        expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
      end
    end
  end

end
