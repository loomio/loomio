require 'rails_helper'
describe API::MembershipsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:user_named_biff) { create :user, name: "Biff Bones" }
  let(:user_named_bang) { create :user, name: "Bang Whamfist" }
  let(:alien_named_biff) { create :user, name: "Biff Beef", email: 'beef@biff.com' }
  let(:alien_named_bang) { create :user, name: 'Bang Beefthrong' }
  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment_params) {{
    body: 'Yo dawg those kittens be trippin for some dippin',
    discussion_id: discussion.id
  }}

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    group.users  << user_named_biff
    group.users  << user_named_bang
    another_group.users << user
    another_group.users << alien_named_bang
    another_group.users << alien_named_biff
    sign_in user
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

      it 'returns users ordered by name' do
        get :index, group_id: group.id, format: :json
        json = JSON.parse(response.body)
        usernames = json['users'].map { |c| c['name'] }
        expect(usernames.sort).to eq usernames
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

  describe 'invitables' do

    context 'success' do
      it 'returns users in shared groups' do
        get :invitables, group_id: group.id, q: 'beef', format: :json
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[users memberships groups])
        users = json['users'].map { |c| c['id'] }
        groups = json['groups'].map { |g| g['id'] }
        expect(users).to include alien_named_biff.id
        expect(users).to include alien_named_bang.id
        expect(users).to_not include user_named_biff.id
        expect(groups).to include another_group.id
      end

      it 'includes the given search fragment' do
        get :invitables, group_id: group.id, q: 'beef', format: :json
        json = JSON.parse(response.body)
        search_fragments = json['users'].map { |c| c['search_fragment'] }
        expect(search_fragments.compact.uniq.length).to eq 1
        expect(search_fragments).to include 'beef'
      end

      it 'can search by email address' do
        get :invitables, group_id: group.id, q: 'beef@biff', format: :json
        json = JSON.parse(response.body)
        users = json['users'].map { |c| c['id'] }
        groups = json['groups'].map { |g| g['id'] }
        expect(users).to include alien_named_biff.id
      end

    end
  end

end
